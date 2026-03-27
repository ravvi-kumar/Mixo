import Foundation

struct TimerPersistenceSnapshot: Equatable {
    var configuration: BreakTimerConfiguration
    var state: BreakTimerStateMachine.State
    var shortBreaksSinceLongBreak: Int
    var currentBreakIsLong: Bool
    var breakElapsedSeconds: Int
}

struct TimerPersistenceService {
    private struct StoredSnapshot: Codable {
        private enum CodingKeys: String, CodingKey {
            case workDurationSeconds
            case shortBreakDurationSeconds
            case breakDurationSeconds
            case longBreakDurationSeconds
            case longBreakEveryShortBreaks
            case breakPolicyMode
            case skipDelaySeconds
            case preBreakNotificationLeadTimeSeconds
            case idlePauseThresholdSeconds
            case longIdleResetThresholdSeconds
            case smartPauseIdleEnabled
            case smartPauseFullscreenEnabled
            case smartPauseMediaEnabled
            case workHoursEnabled
            case workdayStartMinutes
            case workdayEndMinutes
            case mode
            case remainingSeconds
            case shortBreaksSinceLongBreak
            case currentBreakIsLong
            case breakElapsedSeconds
        }

        var workDurationSeconds: Int
        var shortBreakDurationSeconds: Int
        var longBreakDurationSeconds: Int
        var longBreakEveryShortBreaks: Int
        var breakPolicyMode: String
        var skipDelaySeconds: Int
        var preBreakNotificationLeadTimeSeconds: Int
        var idlePauseThresholdSeconds: Int
        var longIdleResetThresholdSeconds: Int
        var smartPauseIdleEnabled: Bool
        var smartPauseFullscreenEnabled: Bool
        var smartPauseMediaEnabled: Bool
        var workHoursEnabled: Bool
        var workdayStartMinutes: Int
        var workdayEndMinutes: Int
        var mode: String
        var remainingSeconds: Int
        var shortBreaksSinceLongBreak: Int
        var currentBreakIsLong: Bool
        var breakElapsedSeconds: Int

        init(
            workDurationSeconds: Int,
            shortBreakDurationSeconds: Int,
            longBreakDurationSeconds: Int,
            longBreakEveryShortBreaks: Int,
            breakPolicyMode: String,
            skipDelaySeconds: Int,
            preBreakNotificationLeadTimeSeconds: Int,
            idlePauseThresholdSeconds: Int,
            longIdleResetThresholdSeconds: Int,
            smartPauseIdleEnabled: Bool,
            smartPauseFullscreenEnabled: Bool,
            smartPauseMediaEnabled: Bool,
            workHoursEnabled: Bool,
            workdayStartMinutes: Int,
            workdayEndMinutes: Int,
            mode: String,
            remainingSeconds: Int,
            shortBreaksSinceLongBreak: Int,
            currentBreakIsLong: Bool,
            breakElapsedSeconds: Int
        ) {
            self.workDurationSeconds = workDurationSeconds
            self.shortBreakDurationSeconds = shortBreakDurationSeconds
            self.longBreakDurationSeconds = longBreakDurationSeconds
            self.longBreakEveryShortBreaks = longBreakEveryShortBreaks
            self.breakPolicyMode = breakPolicyMode
            self.skipDelaySeconds = skipDelaySeconds
            self.preBreakNotificationLeadTimeSeconds = preBreakNotificationLeadTimeSeconds
            self.idlePauseThresholdSeconds = idlePauseThresholdSeconds
            self.longIdleResetThresholdSeconds = longIdleResetThresholdSeconds
            self.smartPauseIdleEnabled = smartPauseIdleEnabled
            self.smartPauseFullscreenEnabled = smartPauseFullscreenEnabled
            self.smartPauseMediaEnabled = smartPauseMediaEnabled
            self.workHoursEnabled = workHoursEnabled
            self.workdayStartMinutes = workdayStartMinutes
            self.workdayEndMinutes = workdayEndMinutes
            self.mode = mode
            self.remainingSeconds = remainingSeconds
            self.shortBreaksSinceLongBreak = shortBreaksSinceLongBreak
            self.currentBreakIsLong = currentBreakIsLong
            self.breakElapsedSeconds = breakElapsedSeconds
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            workDurationSeconds = try container.decodeIfPresent(Int.self, forKey: .workDurationSeconds) ?? 20 * 60
            shortBreakDurationSeconds = try container.decodeIfPresent(Int.self, forKey: .shortBreakDurationSeconds) ??
                (try container.decodeIfPresent(Int.self, forKey: .breakDurationSeconds)) ?? 20
            longBreakDurationSeconds = try container.decodeIfPresent(Int.self, forKey: .longBreakDurationSeconds) ?? 120
            longBreakEveryShortBreaks = try container.decodeIfPresent(Int.self, forKey: .longBreakEveryShortBreaks) ?? 4
            breakPolicyMode = try container.decodeIfPresent(String.self, forKey: .breakPolicyMode) ?? BreakPolicyMode.skipAnytime.rawValue
            skipDelaySeconds = try container.decodeIfPresent(Int.self, forKey: .skipDelaySeconds) ?? 10
            preBreakNotificationLeadTimeSeconds = try container.decodeIfPresent(Int.self, forKey: .preBreakNotificationLeadTimeSeconds) ?? 30
            idlePauseThresholdSeconds = try container.decodeIfPresent(Int.self, forKey: .idlePauseThresholdSeconds) ?? 120
            longIdleResetThresholdSeconds = try container.decodeIfPresent(Int.self, forKey: .longIdleResetThresholdSeconds) ?? 15 * 60
            smartPauseIdleEnabled = try container.decodeIfPresent(Bool.self, forKey: .smartPauseIdleEnabled) ?? true
            smartPauseFullscreenEnabled = try container.decodeIfPresent(Bool.self, forKey: .smartPauseFullscreenEnabled) ?? true
            smartPauseMediaEnabled = try container.decodeIfPresent(Bool.self, forKey: .smartPauseMediaEnabled) ?? true
            workHoursEnabled = try container.decodeIfPresent(Bool.self, forKey: .workHoursEnabled) ?? false
            workdayStartMinutes = try container.decodeIfPresent(Int.self, forKey: .workdayStartMinutes) ?? 9 * 60
            workdayEndMinutes = try container.decodeIfPresent(Int.self, forKey: .workdayEndMinutes) ?? 18 * 60
            mode = try container.decodeIfPresent(String.self, forKey: .mode) ?? "idle"
            remainingSeconds = try container.decodeIfPresent(Int.self, forKey: .remainingSeconds) ?? 0
            shortBreaksSinceLongBreak = try container.decodeIfPresent(Int.self, forKey: .shortBreaksSinceLongBreak) ?? 0
            currentBreakIsLong = try container.decodeIfPresent(Bool.self, forKey: .currentBreakIsLong) ?? false
            breakElapsedSeconds = try container.decodeIfPresent(Int.self, forKey: .breakElapsedSeconds) ?? 0
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(workDurationSeconds, forKey: .workDurationSeconds)
            try container.encode(shortBreakDurationSeconds, forKey: .shortBreakDurationSeconds)
            try container.encode(longBreakDurationSeconds, forKey: .longBreakDurationSeconds)
            try container.encode(longBreakEveryShortBreaks, forKey: .longBreakEveryShortBreaks)
            try container.encode(breakPolicyMode, forKey: .breakPolicyMode)
            try container.encode(skipDelaySeconds, forKey: .skipDelaySeconds)
            try container.encode(preBreakNotificationLeadTimeSeconds, forKey: .preBreakNotificationLeadTimeSeconds)
            try container.encode(idlePauseThresholdSeconds, forKey: .idlePauseThresholdSeconds)
            try container.encode(longIdleResetThresholdSeconds, forKey: .longIdleResetThresholdSeconds)
            try container.encode(smartPauseIdleEnabled, forKey: .smartPauseIdleEnabled)
            try container.encode(smartPauseFullscreenEnabled, forKey: .smartPauseFullscreenEnabled)
            try container.encode(smartPauseMediaEnabled, forKey: .smartPauseMediaEnabled)
            try container.encode(workHoursEnabled, forKey: .workHoursEnabled)
            try container.encode(workdayStartMinutes, forKey: .workdayStartMinutes)
            try container.encode(workdayEndMinutes, forKey: .workdayEndMinutes)
            try container.encode(mode, forKey: .mode)
            try container.encode(remainingSeconds, forKey: .remainingSeconds)
            try container.encode(shortBreaksSinceLongBreak, forKey: .shortBreaksSinceLongBreak)
            try container.encode(currentBreakIsLong, forKey: .currentBreakIsLong)
            try container.encode(breakElapsedSeconds, forKey: .breakElapsedSeconds)
        }
    }

    private let defaults: UserDefaults
    private let key: String

    init(
        defaults: UserDefaults = .standard,
        key: String = "mixo.timer.snapshot.v1"
    ) {
        self.defaults = defaults
        self.key = key
    }

    func save(machine: BreakTimerStateMachine) {
        let configuration = machine.configuration
        let stored = StoredSnapshot(
            workDurationSeconds: max(configuration.workDurationSeconds, 1),
            shortBreakDurationSeconds: max(configuration.shortBreakDurationSeconds, 1),
            longBreakDurationSeconds: max(configuration.longBreakDurationSeconds, 1),
            longBreakEveryShortBreaks: max(configuration.longBreakEveryShortBreaks, 1),
            breakPolicyMode: configuration.breakPolicyMode.rawValue,
            skipDelaySeconds: max(configuration.skipDelaySeconds, 0),
            preBreakNotificationLeadTimeSeconds: max(configuration.preBreakNotificationLeadTimeSeconds, 0),
            idlePauseThresholdSeconds: max(configuration.idlePauseThresholdSeconds, 0),
            longIdleResetThresholdSeconds: max(configuration.longIdleResetThresholdSeconds, 0),
            smartPauseIdleEnabled: configuration.smartPauseIdleEnabled,
            smartPauseFullscreenEnabled: configuration.smartPauseFullscreenEnabled,
            smartPauseMediaEnabled: configuration.smartPauseMediaEnabled,
            workHoursEnabled: configuration.workHoursEnabled,
            workdayStartMinutes: configuration.workdayStartMinutes,
            workdayEndMinutes: configuration.workdayEndMinutes,
            mode: modeString(from: machine.state),
            remainingSeconds: remainingSeconds(from: machine.state),
            shortBreaksSinceLongBreak: max(machine.shortBreaksSinceLongBreak, 0),
            currentBreakIsLong: machine.currentBreakIsLong,
            breakElapsedSeconds: max(machine.breakElapsedSeconds, 0)
        )

        guard let data = try? JSONEncoder().encode(stored) else {
            return
        }
        defaults.set(data, forKey: key)
    }

    func load() -> TimerPersistenceSnapshot? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        guard let stored = try? JSONDecoder().decode(StoredSnapshot.self, from: data) else {
            defaults.removeObject(forKey: key)
            return nil
        }

        let configuration = BreakTimerConfiguration(
            workDurationSeconds: max(stored.workDurationSeconds, 1),
            breakDurationSeconds: max(stored.shortBreakDurationSeconds, 1),
            longBreakDurationSeconds: max(stored.longBreakDurationSeconds, 1),
            longBreakEveryShortBreaks: max(stored.longBreakEveryShortBreaks, 1),
            breakPolicyMode: BreakPolicyMode(rawValue: stored.breakPolicyMode) ?? .skipAnytime,
            skipDelaySeconds: max(stored.skipDelaySeconds, 0),
            preBreakNotificationLeadTimeSeconds: max(stored.preBreakNotificationLeadTimeSeconds, 0),
            idlePauseThresholdSeconds: max(stored.idlePauseThresholdSeconds, 0),
            longIdleResetThresholdSeconds: max(stored.longIdleResetThresholdSeconds, 0),
            smartPauseIdleEnabled: stored.smartPauseIdleEnabled,
            smartPauseFullscreenEnabled: stored.smartPauseFullscreenEnabled,
            smartPauseMediaEnabled: stored.smartPauseMediaEnabled,
            workHoursEnabled: stored.workHoursEnabled,
            workdayStartMinutes: stored.workdayStartMinutes,
            workdayEndMinutes: stored.workdayEndMinutes
        )

        guard let state = state(from: stored, configuration: configuration) else {
            defaults.removeObject(forKey: key)
            return nil
        }

        return TimerPersistenceSnapshot(
            configuration: configuration,
            state: state,
            shortBreaksSinceLongBreak: max(stored.shortBreaksSinceLongBreak, 0),
            currentBreakIsLong: stored.currentBreakIsLong,
            breakElapsedSeconds: max(stored.breakElapsedSeconds, 0)
        )
    }

    private func modeString(from state: BreakTimerStateMachine.State) -> String {
        switch state {
        case .idle:
            return "idle"
        case .running:
            return "running"
        case .paused:
            return "paused"
        case .takingBreak:
            return "takingBreak"
        }
    }

    private func remainingSeconds(from state: BreakTimerStateMachine.State) -> Int {
        switch state {
        case .idle:
            return 0
        case let .running(remaining), let .paused(remaining), let .takingBreak(remaining):
            return remaining
        }
    }

    private func state(
        from stored: StoredSnapshot,
        configuration: BreakTimerConfiguration
    ) -> BreakTimerStateMachine.State? {
        switch stored.mode {
        case "idle":
            return .idle
        case "running":
            return .running(
                remaining: min(max(stored.remainingSeconds, 1), max(configuration.workDurationSeconds, 1))
            )
        case "paused":
            return .paused(
                remaining: min(max(stored.remainingSeconds, 1), max(configuration.workDurationSeconds, 1))
            )
        case "takingBreak":
            return .takingBreak(
                remaining: min(
                    max(stored.remainingSeconds, 1),
                    max(
                        stored.currentBreakIsLong ? configuration.longBreakDurationSeconds : configuration.shortBreakDurationSeconds,
                        1
                    )
                )
            )
        default:
            return nil
        }
    }
}
