import AppKit
import Foundation
import UserNotifications

@MainActor
final class AppState: ObservableObject {
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    @Published var timerMode: BreakTimerStateMachine.Mode = .idle
    @Published var timerRemainingSeconds: Int = 0
    @Published var timerWorkDurationMinutes: Int
    @Published var timerBreakDurationSeconds: Int
    @Published var timerLongBreakDurationMinutes: Int
    @Published var timerLongBreakEveryShortBreaks: Int
    @Published var timerBreakPolicyMode: BreakPolicyMode
    @Published var timerSkipDelaySeconds: Int
    @Published var timerPreBreakNotificationLeadTimeSeconds: Int
    @Published var notificationFallbackStatus: String?
    @Published var lastActionMessage = "App started"

    var menuBarLabel: String {
        "Mixo"
    }

    var notificationStatusDisplay: String {
        switch notificationStatus {
        case .notDetermined:
            return "Not requested"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }

    var timerModeDisplay: String {
        switch timerMode {
        case .idle:
            return "Idle"
        case .running:
            return "Running"
        case .paused:
            return "Paused"
        case .takingBreak:
            return timerStateMachine.isLongBreakActive ? "Long Break" : "Break"
        }
    }

    var timerRemainingDisplay: String {
        Self.formatDuration(timerRemainingSeconds)
    }

    var shortBreaksUntilLongBreakDisplay: String {
        String(timerStateMachine.shortBreaksUntilLongBreak)
    }

    var breakPolicyModeDisplay: String {
        switch timerStateMachine.configuration.breakPolicyMode {
        case .skipAnytime:
            return "Skip Anytime"
        case .skipAfterDelay:
            return "Skip After Delay"
        case .lock:
            return "Lock"
        }
    }

    var preBreakNotificationLeadTimeDisplay: String {
        if timerStateMachine.configuration.preBreakNotificationLeadTimeSeconds == 0 {
            return "Off"
        }
        return "\(timerStateMachine.configuration.preBreakNotificationLeadTimeSeconds)s"
    }

    var notificationFallbackStatusDisplay: String {
        notificationFallbackStatus ?? "Healthy"
    }

    var canStartTimer: Bool {
        timerMode == .idle
    }

    var canPauseTimer: Bool {
        timerMode == .running
    }

    var canResumeTimer: Bool {
        timerMode == .paused
    }

    var canTakeBreakNow: Bool {
        timerMode == .running || timerMode == .paused
    }

    var canSkipBreak: Bool {
        timerStateMachine.canSkipBreak
    }

    var shouldShowSkipBreakAction: Bool {
        !(timerMode == .takingBreak && timerStateMachine.configuration.breakPolicyMode == .lock)
    }

    var canResetTimer: Bool {
        timerMode != .idle
    }

    var canApplyTimerSettings: Bool {
        timerMode == .idle
    }

    private var canDeliverNotificationHeadsUp: Bool {
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        @unknown default:
            return false
        }
    }

    private let notificationService: NotificationPermissionService
    private let timerPersistenceService: TimerPersistenceService
    private let overlayWindowManager: OverlayWindowManager
    private let headsUpFloatingCountdownManager: HeadsUpFloatingCountdownManager
    private let breakChimeService: any BreakChimePlaying
    private let logger = AppLogger.make("state")
    private var timerStateMachine: BreakTimerStateMachine
    private var tickTask: Task<Void, Never>?
    private var headsUpActionObserver: NSObjectProtocol?

    init(
        notificationService: NotificationPermissionService = .init(),
        timerPersistenceService: TimerPersistenceService = .init(),
        overlayWindowManager: OverlayWindowManager? = nil,
        headsUpFloatingCountdownManager: HeadsUpFloatingCountdownManager? = nil,
        breakChimeService: (any BreakChimePlaying)? = nil,
        timerConfiguration: BreakTimerConfiguration = .default
    ) {
        self.notificationService = notificationService
        self.timerPersistenceService = timerPersistenceService
        self.overlayWindowManager = overlayWindowManager ?? OverlayWindowManager()
        self.headsUpFloatingCountdownManager = headsUpFloatingCountdownManager ?? HeadsUpFloatingCountdownManager()
        self.breakChimeService = breakChimeService ?? BreakChimeService()

        let restoredSnapshot = timerPersistenceService.load()
        let restoredConfiguration = restoredSnapshot?.configuration ?? timerConfiguration

        timerWorkDurationMinutes = max(1, restoredConfiguration.workDurationSeconds / 60)
        timerBreakDurationSeconds = max(5, restoredConfiguration.breakDurationSeconds)
        timerLongBreakDurationMinutes = max(1, restoredConfiguration.longBreakDurationSeconds / 60)
        timerLongBreakEveryShortBreaks = max(1, restoredConfiguration.longBreakEveryShortBreaks)
        timerBreakPolicyMode = restoredConfiguration.breakPolicyMode
        timerSkipDelaySeconds = max(0, restoredConfiguration.skipDelaySeconds)
        timerPreBreakNotificationLeadTimeSeconds = max(0, restoredConfiguration.preBreakNotificationLeadTimeSeconds)

        if let restoredSnapshot {
            timerStateMachine = BreakTimerStateMachine(
                configuration: restoredSnapshot.configuration,
                state: restoredSnapshot.state,
                shortBreaksSinceLongBreak: restoredSnapshot.shortBreaksSinceLongBreak,
                currentBreakIsLong: restoredSnapshot.currentBreakIsLong,
                breakElapsedSeconds: restoredSnapshot.breakElapsedSeconds
            )
            lastActionMessage = "Timer restored from last session"
        } else {
            timerStateMachine = BreakTimerStateMachine(configuration: restoredConfiguration)
        }

        syncTimerStateFromMachine()
        updateHeadsUpMiniCountdown()
        updateTickLoop()
        updateOverlayForTimerState()

        if let restoredSnapshot {
            logger.info(
                "timer_state_restored state=\(self.timerStateMachine.stateDescription, privacy: .public) work_seconds=\(restoredSnapshot.configuration.workDurationSeconds, privacy: .public) short_break_seconds=\(restoredSnapshot.configuration.shortBreakDurationSeconds, privacy: .public) long_break_seconds=\(restoredSnapshot.configuration.longBreakDurationSeconds, privacy: .public) cadence=\(restoredSnapshot.configuration.longBreakEveryShortBreaks, privacy: .public) policy=\(restoredSnapshot.configuration.breakPolicyMode.rawValue, privacy: .public) skip_delay=\(restoredSnapshot.configuration.skipDelaySeconds, privacy: .public) heads_up_lead=\(restoredSnapshot.configuration.preBreakNotificationLeadTimeSeconds, privacy: .public)"
            )
        }

        self.overlayWindowManager.setEmergencyDismissHandler { [weak self] in
            self?.handleOverlayEmergencyDismiss()
        }

        headsUpActionObserver = NotificationCenter.default.addObserver(
            forName: .mixoHeadsUpActionInvoked,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else {
                return
            }

            guard
                let commandRaw = notification.userInfo?[HeadsUpNotificationConstants.commandUserInfoKey] as? String,
                let command = HeadsUpActionCommand(rawValue: commandRaw)
            else {
                return
            }

            let delaySeconds =
                (notification.userInfo?[HeadsUpNotificationConstants.delaySecondsUserInfoKey] as? Int) ??
                (notification.userInfo?[HeadsUpNotificationConstants.delaySecondsUserInfoKey] as? NSNumber)?.intValue ??
                HeadsUpNotificationConstants.defaultDelaySeconds
            self.handleHeadsUpAction(command, delaySeconds: delaySeconds)
        }

        Task { [weak self] in
            await self?.refreshNotificationStatus()
        }
    }

    deinit {
        if let headsUpActionObserver {
            NotificationCenter.default.removeObserver(headsUpActionObserver)
        }
    }

    func openSettingsLegacy() {
        logger.info("action_open_settings_legacy")
        lastActionMessage = "Opened settings"
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    func requestNotificationPermission() {
        logger.info("action_request_notification_permission")
        Task {
            do {
                _ = try await notificationService.requestAuthorization()
                await refreshNotificationStatus()
                lastActionMessage = "Notification permission updated"
            } catch let NotificationPermissionService.ServiceError.unsupportedExecutionContext(reason) {
                logger.error("notification_permission_unsupported_context reason=\(reason, privacy: .public)")
                lastActionMessage = reason
            } catch {
                logger.error("notification_permission_error: \(String(describing: error), privacy: .public)")
                lastActionMessage = "Notification permission request failed"
            }
        }
    }

    func startTimer() {
        logger.info("action_timer_start")
        if applyTimerEvent(.start) {
            lastActionMessage = "Timer started"
        } else {
            lastActionMessage = "Start ignored for current timer state"
        }
    }

    func pauseTimer() {
        logger.info("action_timer_pause")
        if applyTimerEvent(.pause) {
            lastActionMessage = "Timer paused"
        } else {
            lastActionMessage = "Pause ignored for current timer state"
        }
    }

    func resumeTimer() {
        logger.info("action_timer_resume")
        if applyTimerEvent(.resume) {
            lastActionMessage = "Timer resumed"
        } else {
            lastActionMessage = "Resume ignored for current timer state"
        }
    }

    func takeBreakNow() {
        logger.info("action_timer_take_break_now")
        if applyTimerEvent(.forceBreak) {
            lastActionMessage = "Break started"
        } else {
            lastActionMessage = "Take break ignored for current timer state"
        }
    }

    func resetTimer() {
        logger.info("action_timer_reset")
        if applyTimerEvent(.reset) {
            lastActionMessage = "Timer reset"
        } else {
            lastActionMessage = "Reset ignored for current timer state"
        }
    }

    func skipBreak() {
        logger.info("action_timer_skip_break")
        if applyTimerEvent(.skipBreak) {
            lastActionMessage = "Break skipped"
        } else {
            lastActionMessage = "Skip break unavailable in current state"
        }
    }

    func handleHeadsUpAction(
        _ command: HeadsUpActionCommand,
        delaySeconds: Int = HeadsUpNotificationConstants.defaultDelaySeconds
    ) {
        switch command {
        case .startNow:
            logger.info("notification_action_start_now_received")
            if applyTimerEvent(.forceBreak) {
                lastActionMessage = "Break started from notification action"
            } else {
                lastActionMessage = "Notification start-now ignored in current state"
            }
        case .delay:
            let boundedDelay = max(delaySeconds, 1)
            logger.info("notification_action_delay_received delay_seconds=\(boundedDelay, privacy: .public)")
            if delayUpcomingBreak(by: boundedDelay) {
                let minutes = boundedDelay / 60
                let remainder = boundedDelay % 60
                if remainder == 0 {
                    lastActionMessage = "Break delayed by \(minutes) min from notification"
                } else {
                    lastActionMessage = "Break delayed by \(boundedDelay) sec from notification"
                }
            } else {
                lastActionMessage = "Notification delay ignored in current state"
            }
        }
    }

    func showOverlayPreview() {
        logger.info("action_show_overlay_preview")
        overlayWindowManager.showPreviewOverlay()
        lastActionMessage = "Overlay preview shown"
    }

    func hideOverlay() {
        logger.info("action_hide_overlay")
        overlayWindowManager.hideOverlay()
        lastActionMessage = "Overlay hidden"
    }

    func logOverlayDiagnostics() {
        let diagnostics = overlayWindowManager.diagnostics()
        logger.info(
            "overlay_diagnostics mode=\(diagnostics.mode, privacy: .public) windows=\(diagnostics.windowCount, privacy: .public) screens=\(diagnostics.screenCount, privacy: .public)"
        )
        lastActionMessage = "Overlay diagnostics: \(diagnostics.windowCount) windows / \(diagnostics.screenCount) screens (\(diagnostics.mode))"
    }

    func applyTimerSettings() {
        guard canApplyTimerSettings else {
            lastActionMessage = "Stop timer before applying settings"
            return
        }

        let workMinutes = max(1, timerWorkDurationMinutes)
        let breakSeconds = max(5, timerBreakDurationSeconds)
        let longBreakMinutes = max(1, timerLongBreakDurationMinutes)
        let longBreakEvery = max(1, timerLongBreakEveryShortBreaks)
        let skipDelaySeconds = max(0, timerSkipDelaySeconds)
        let notificationLeadTimeSeconds = max(0, timerPreBreakNotificationLeadTimeSeconds)
        timerWorkDurationMinutes = workMinutes
        timerBreakDurationSeconds = breakSeconds
        timerLongBreakDurationMinutes = longBreakMinutes
        timerLongBreakEveryShortBreaks = longBreakEvery
        timerSkipDelaySeconds = skipDelaySeconds
        timerPreBreakNotificationLeadTimeSeconds = notificationLeadTimeSeconds

        let configuration = BreakTimerConfiguration(
            workDurationSeconds: workMinutes * 60,
            breakDurationSeconds: breakSeconds,
            longBreakDurationSeconds: longBreakMinutes * 60,
            longBreakEveryShortBreaks: longBreakEvery,
            breakPolicyMode: timerBreakPolicyMode,
            skipDelaySeconds: skipDelaySeconds,
            preBreakNotificationLeadTimeSeconds: notificationLeadTimeSeconds
        )
        timerStateMachine = BreakTimerStateMachine(configuration: configuration)
        syncTimerStateFromMachine()
        updateHeadsUpMiniCountdown()
        updateTickLoop()
        updateOverlayForTimerState()
        persistTimerSnapshot()
        syncHeadsUpNotificationSchedule()

        logger.info(
            "timer_configuration_updated work_seconds=\((workMinutes * 60), privacy: .public) short_break_seconds=\(breakSeconds, privacy: .public) long_break_seconds=\((longBreakMinutes * 60), privacy: .public) cadence=\(longBreakEvery, privacy: .public) policy=\(self.timerBreakPolicyMode.rawValue, privacy: .public) skip_delay=\(skipDelaySeconds, privacy: .public) heads_up_lead=\(notificationLeadTimeSeconds, privacy: .public)"
        )
        lastActionMessage = "Timer settings updated"
    }

    func refreshNotificationStatus() async {
        let status = await notificationService.currentStatus()
        notificationStatus = status
        logger.info("notification_status=\(status.rawValue)")
        syncHeadsUpNotificationSchedule()
    }

    private func handleTick() {
        _ = applyTimerEvent(.tick)
    }

    @discardableResult
    private func applyTimerEvent(_ event: BreakTimerStateMachine.Event) -> Bool {
        let previousMode = timerStateMachine.mode
        let previousState = timerStateMachine.stateDescription
        let changed = timerStateMachine.handle(event)

        if changed {
            syncTimerStateFromMachine()
            updateHeadsUpMiniCountdown()
            let currentState = timerStateMachine.stateDescription
            logger.info(
                "timer_transition event=\(event.rawValue, privacy: .public) from=\(previousState, privacy: .public) to=\(currentState, privacy: .public)"
            )
            updateTickLoop()
            updateOverlayForTimerState()
            persistTimerSnapshot()
            if event != .tick || previousMode != timerMode {
                syncHeadsUpNotificationSchedule()
            }

            if previousMode != .takingBreak, timerMode == .takingBreak {
                breakChimeService.playBreakStartChime()
                logger.info("break_started")
            }

            if previousMode == .takingBreak, timerMode == .running {
                breakChimeService.playBreakEndChime()
                logger.info("break_completed")
            }
        } else {
            logger.info(
                "timer_event_ignored event=\(event.rawValue, privacy: .public) state=\(previousState, privacy: .public)"
            )
        }

        return changed
    }

    private func syncTimerStateFromMachine() {
        timerMode = timerStateMachine.mode
        timerRemainingSeconds = timerStateMachine.remainingSeconds
    }

    private func updateTickLoop() {
        let shouldTick = timerMode == .running || timerMode == .takingBreak

        if shouldTick {
            guard tickTask == nil else {
                return
            }

            tickTask = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    guard !Task.isCancelled else {
                        return
                    }
                    self?.handleTick()
                }
            }
            return
        }

        tickTask?.cancel()
        tickTask = nil
    }

    private func updateHeadsUpMiniCountdown() {
        guard timerMode == .running else {
            headsUpFloatingCountdownManager.hide()
            return
        }

        let leadTimeSeconds = max(timerStateMachine.configuration.preBreakNotificationLeadTimeSeconds, 0)
        guard leadTimeSeconds > 0, timerRemainingSeconds <= leadTimeSeconds, timerRemainingSeconds > 0 else {
            headsUpFloatingCountdownManager.hide()
            return
        }

        let upcomingLongBreak = timerStateMachine.shortBreaksUntilLongBreak == 1
        headsUpFloatingCountdownManager.show(
            remainingSeconds: timerRemainingSeconds,
            isLongBreak: upcomingLongBreak
        )
    }

    private func syncHeadsUpNotificationSchedule() {
        Task { [weak self] in
            await self?.updateHeadsUpNotificationSchedule()
        }
    }

    private func delayUpcomingBreak(by seconds: Int) -> Bool {
        let previousState = timerStateMachine.stateDescription
        let changed = timerStateMachine.delayUpcomingBreak(by: seconds)

        guard changed else {
            logger.info(
                "timer_break_delay_ignored state=\(previousState, privacy: .public) delay_seconds=\(seconds, privacy: .public)"
            )
            return false
        }

        syncTimerStateFromMachine()
        updateHeadsUpMiniCountdown()
        updateTickLoop()
        updateOverlayForTimerState()
        persistTimerSnapshot()
        syncHeadsUpNotificationSchedule()
        logger.info(
            "timer_break_delayed from=\(previousState, privacy: .public) to=\(self.timerStateMachine.stateDescription, privacy: .public) delay_seconds=\(seconds, privacy: .public)"
        )
        return true
    }

    private func updateHeadsUpNotificationSchedule() async {
        guard timerMode == .running else {
            notificationService.clearPreBreakReminder()
            clearNotificationFallbackStatus()
            return
        }

        let leadTimeSeconds = max(timerStateMachine.configuration.preBreakNotificationLeadTimeSeconds, 0)
        guard leadTimeSeconds > 0 else {
            notificationService.clearPreBreakReminder()
            clearNotificationFallbackStatus()
            return
        }

        guard canDeliverNotificationHeadsUp else {
            notificationService.clearPreBreakReminder()
            setNotificationFallbackStatus(
                "Heads-up notification unavailable (\(notificationStatusDisplay)). Mini countdown remains active."
            )
            return
        }

        let upcomingLongBreak = timerStateMachine.shortBreaksUntilLongBreak == 1
        let scheduleInSeconds = max(timerRemainingSeconds - leadTimeSeconds, 1)

        do {
            try await notificationService.schedulePreBreakReminder(
                in: scheduleInSeconds,
                leadTimeSeconds: leadTimeSeconds,
                isLongBreak: upcomingLongBreak
            )
            logger.info(
                "notification_heads_up_scheduled in_seconds=\(scheduleInSeconds, privacy: .public) lead_seconds=\(leadTimeSeconds, privacy: .public) next_is_long_break=\(upcomingLongBreak, privacy: .public)"
            )
            clearNotificationFallbackStatus()
        } catch let NotificationPermissionService.ServiceError.unsupportedExecutionContext(reason) {
            logger.error("notification_heads_up_unsupported_context reason=\(reason, privacy: .public)")
            setNotificationFallbackStatus("Heads-up notification unavailable: \(reason)")
        } catch {
            logger.error("notification_heads_up_schedule_failed error=\(String(describing: error), privacy: .public)")
            setNotificationFallbackStatus("Heads-up notification scheduling failed. Mini countdown remains active.")
        }
    }

    private func setNotificationFallbackStatus(_ message: String) {
        guard notificationFallbackStatus != message else {
            return
        }
        notificationFallbackStatus = message
        logger.error("notification_fallback_status message=\(message, privacy: .public)")
    }

    private func clearNotificationFallbackStatus() {
        guard notificationFallbackStatus != nil else {
            return
        }
        notificationFallbackStatus = nil
        logger.info("notification_fallback_cleared")
    }

    private static func formatDuration(_ totalSeconds: Int) -> String {
        let bounded = max(0, totalSeconds)
        let minutes = bounded / 60
        let seconds = bounded % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func persistTimerSnapshot() {
        timerPersistenceService.save(machine: timerStateMachine)
    }

    private func updateOverlayForTimerState() {
        if timerMode == .takingBreak {
            overlayWindowManager.showBreakOverlay(remainingSeconds: timerRemainingSeconds)
            return
        }

        overlayWindowManager.hideOverlay()
    }

    private func handleOverlayEmergencyDismiss() {
        logger.info("action_overlay_emergency_dismiss")

        if timerMode == .takingBreak, applyTimerEvent(.dismissBreak) {
            lastActionMessage = "Break dismissed (emergency)"
            return
        }

        overlayWindowManager.hideOverlay()
        lastActionMessage = "Overlay dismissed"
    }
}
