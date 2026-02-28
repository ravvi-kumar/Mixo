import Foundation

struct BreakTimerConfiguration: Equatable {
    var workDurationSeconds: Int
    var breakDurationSeconds: Int

    static let `default` = BreakTimerConfiguration(
        workDurationSeconds: 20 * 60,
        breakDurationSeconds: 20
    )
}

struct BreakTimerStateMachine {
    enum Mode: String {
        case idle
        case running
        case paused
        case takingBreak
    }

    enum Event: String {
        case start
        case pause
        case resume
        case tick
        case forceBreak
        case reset
    }

    enum State: Equatable {
        case idle
        case running(remaining: Int)
        case paused(remaining: Int)
        case takingBreak(remaining: Int)
    }

    private(set) var state: State = .idle
    let configuration: BreakTimerConfiguration

    init(configuration: BreakTimerConfiguration = .default) {
        self.configuration = configuration
    }

    init(configuration: BreakTimerConfiguration = .default, state: State) {
        self.configuration = configuration
        self.state = Self.normalizedState(state, configuration: configuration)
    }

    var mode: Mode {
        switch state {
        case .idle:
            return .idle
        case .running:
            return .running
        case .paused:
            return .paused
        case .takingBreak:
            return .takingBreak
        }
    }

    var remainingSeconds: Int {
        switch state {
        case .idle:
            return 0
        case let .running(remaining):
            return remaining
        case let .paused(remaining):
            return remaining
        case let .takingBreak(remaining):
            return remaining
        }
    }

    @discardableResult
    mutating func handle(_ event: Event) -> Bool {
        switch (state, event) {
        case (.idle, .start):
            state = .running(remaining: configuration.workDurationSeconds)
            return true

        case let (.running(remaining), .pause):
            state = .paused(remaining: remaining)
            return true

        case let (.paused(remaining), .resume):
            state = .running(remaining: remaining)
            return true

        case let (.running(remaining), .tick):
            let next = remaining - 1
            if next > 0 {
                state = .running(remaining: next)
            } else {
                state = .takingBreak(remaining: configuration.breakDurationSeconds)
            }
            return true

        case let (.takingBreak(remaining), .tick):
            let next = remaining - 1
            if next > 0 {
                state = .takingBreak(remaining: next)
            } else {
                state = .running(remaining: configuration.workDurationSeconds)
            }
            return true

        case (.running, .forceBreak), (.paused, .forceBreak):
            state = .takingBreak(remaining: configuration.breakDurationSeconds)
            return true

        case (.idle, .reset), (.running, .reset), (.paused, .reset), (.takingBreak, .reset):
            state = .idle
            return true

        default:
            return false
        }
    }

    var stateDescription: String {
        switch state {
        case .idle:
            return "idle"
        case let .running(remaining):
            return "running(\(remaining))"
        case let .paused(remaining):
            return "paused(\(remaining))"
        case let .takingBreak(remaining):
            return "takingBreak(\(remaining))"
        }
    }

    private static func normalizedState(_ state: State, configuration: BreakTimerConfiguration) -> State {
        switch state {
        case .idle:
            return .idle
        case let .running(remaining):
            return .running(remaining: min(max(remaining, 1), max(configuration.workDurationSeconds, 1)))
        case let .paused(remaining):
            return .paused(remaining: min(max(remaining, 1), max(configuration.workDurationSeconds, 1)))
        case let .takingBreak(remaining):
            return .takingBreak(remaining: min(max(remaining, 1), max(configuration.breakDurationSeconds, 1)))
        }
    }
}
