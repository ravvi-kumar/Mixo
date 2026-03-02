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

    private let notificationService: NotificationPermissionService
    private let timerPersistenceService: TimerPersistenceService
    private let overlayWindowManager: OverlayWindowManager
    private let breakChimeService: any BreakChimePlaying
    private let logger = AppLogger.make("state")
    private var timerStateMachine: BreakTimerStateMachine
    private var tickTask: Task<Void, Never>?

    init(
        notificationService: NotificationPermissionService = .init(),
        timerPersistenceService: TimerPersistenceService = .init(),
        overlayWindowManager: OverlayWindowManager? = nil,
        breakChimeService: (any BreakChimePlaying)? = nil,
        timerConfiguration: BreakTimerConfiguration = .default
    ) {
        self.notificationService = notificationService
        self.timerPersistenceService = timerPersistenceService
        self.overlayWindowManager = overlayWindowManager ?? OverlayWindowManager()
        self.breakChimeService = breakChimeService ?? BreakChimeService()

        let restoredSnapshot = timerPersistenceService.load()
        let restoredConfiguration = restoredSnapshot?.configuration ?? timerConfiguration

        timerWorkDurationMinutes = max(1, restoredConfiguration.workDurationSeconds / 60)
        timerBreakDurationSeconds = max(5, restoredConfiguration.breakDurationSeconds)
        timerLongBreakDurationMinutes = max(1, restoredConfiguration.longBreakDurationSeconds / 60)
        timerLongBreakEveryShortBreaks = max(1, restoredConfiguration.longBreakEveryShortBreaks)
        timerBreakPolicyMode = restoredConfiguration.breakPolicyMode
        timerSkipDelaySeconds = max(0, restoredConfiguration.skipDelaySeconds)

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
        updateTickLoop()
        updateOverlayForTimerState()

        if let restoredSnapshot {
            logger.info(
                "timer_state_restored state=\(self.timerStateMachine.stateDescription, privacy: .public) work_seconds=\(restoredSnapshot.configuration.workDurationSeconds, privacy: .public) short_break_seconds=\(restoredSnapshot.configuration.shortBreakDurationSeconds, privacy: .public) long_break_seconds=\(restoredSnapshot.configuration.longBreakDurationSeconds, privacy: .public) cadence=\(restoredSnapshot.configuration.longBreakEveryShortBreaks, privacy: .public) policy=\(restoredSnapshot.configuration.breakPolicyMode.rawValue, privacy: .public)"
            )
        }

        self.overlayWindowManager.setEmergencyDismissHandler { [weak self] in
            self?.handleOverlayEmergencyDismiss()
        }

        Task { [weak self] in
            await self?.refreshNotificationStatus()
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
        timerWorkDurationMinutes = workMinutes
        timerBreakDurationSeconds = breakSeconds
        timerLongBreakDurationMinutes = longBreakMinutes
        timerLongBreakEveryShortBreaks = longBreakEvery
        timerSkipDelaySeconds = skipDelaySeconds

        let configuration = BreakTimerConfiguration(
            workDurationSeconds: workMinutes * 60,
            breakDurationSeconds: breakSeconds,
            longBreakDurationSeconds: longBreakMinutes * 60,
            longBreakEveryShortBreaks: longBreakEvery,
            breakPolicyMode: timerBreakPolicyMode,
            skipDelaySeconds: skipDelaySeconds
        )
        timerStateMachine = BreakTimerStateMachine(configuration: configuration)
        syncTimerStateFromMachine()
        updateTickLoop()
        updateOverlayForTimerState()
        persistTimerSnapshot()

        logger.info(
            "timer_configuration_updated work_seconds=\((workMinutes * 60), privacy: .public) short_break_seconds=\(breakSeconds, privacy: .public) long_break_seconds=\((longBreakMinutes * 60), privacy: .public) cadence=\(longBreakEvery, privacy: .public) policy=\(self.timerBreakPolicyMode.rawValue, privacy: .public) skip_delay=\(skipDelaySeconds, privacy: .public)"
        )
        lastActionMessage = "Timer settings updated"
    }

    func refreshNotificationStatus() async {
        let status = await notificationService.currentStatus()
        notificationStatus = status
        logger.info("notification_status=\(status.rawValue)")
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
            let currentState = timerStateMachine.stateDescription
            logger.info(
                "timer_transition event=\(event.rawValue, privacy: .public) from=\(previousState, privacy: .public) to=\(currentState, privacy: .public)"
            )
            updateTickLoop()
            updateOverlayForTimerState()
            persistTimerSnapshot()

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
