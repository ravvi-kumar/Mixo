import Foundation

struct TimerPersistenceSnapshot: Equatable {
    var configuration: BreakTimerConfiguration
    var state: BreakTimerStateMachine.State
}

struct TimerPersistenceService {
    private struct StoredSnapshot: Codable {
        var workDurationSeconds: Int
        var breakDurationSeconds: Int
        var mode: String
        var remainingSeconds: Int
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

    func save(configuration: BreakTimerConfiguration, state: BreakTimerStateMachine.State) {
        let stored = StoredSnapshot(
            workDurationSeconds: max(configuration.workDurationSeconds, 1),
            breakDurationSeconds: max(configuration.breakDurationSeconds, 1),
            mode: modeString(from: state),
            remainingSeconds: remainingSeconds(from: state)
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
            breakDurationSeconds: max(stored.breakDurationSeconds, 1)
        )

        guard let state = state(from: stored, configuration: configuration) else {
            defaults.removeObject(forKey: key)
            return nil
        }

        return TimerPersistenceSnapshot(configuration: configuration, state: state)
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
                remaining: min(max(stored.remainingSeconds, 1), max(configuration.breakDurationSeconds, 1))
            )
        default:
            return nil
        }
    }
}
