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
            skipDelaySeconds: max(stored.skipDelaySeconds, 0)
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
