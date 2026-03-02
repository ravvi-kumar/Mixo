import Foundation

enum BreakPolicyMode: String, CaseIterable, Equatable {
    case skipAnytime
    case skipAfterDelay
    case lock
}

struct BreakTimerConfiguration: Equatable {
    var workDurationSeconds: Int
    var shortBreakDurationSeconds: Int
    var longBreakDurationSeconds: Int
    var longBreakEveryShortBreaks: Int
    var breakPolicyMode: BreakPolicyMode
    var skipDelaySeconds: Int

    // Backward-compatible alias used by earlier code/tests.
    var breakDurationSeconds: Int {
        get { shortBreakDurationSeconds }
        set { shortBreakDurationSeconds = max(1, newValue) }
    }

    init(
        workDurationSeconds: Int,
        breakDurationSeconds: Int,
        longBreakDurationSeconds: Int = 120,
        longBreakEveryShortBreaks: Int = 4,
        breakPolicyMode: BreakPolicyMode = .skipAnytime,
        skipDelaySeconds: Int = 10
    ) {
        self.workDurationSeconds = max(1, workDurationSeconds)
        shortBreakDurationSeconds = max(1, breakDurationSeconds)
        self.longBreakDurationSeconds = max(1, longBreakDurationSeconds)
        self.longBreakEveryShortBreaks = max(1, longBreakEveryShortBreaks)
        self.breakPolicyMode = breakPolicyMode
        self.skipDelaySeconds = max(0, skipDelaySeconds)
    }

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
        case skipBreak
        case dismissBreak
        case reset
    }

    enum State: Equatable {
        case idle
        case running(remaining: Int)
        case paused(remaining: Int)
        case takingBreak(remaining: Int)
    }

    private(set) var state: State = .idle
    private(set) var shortBreaksSinceLongBreak = 0
    private(set) var currentBreakIsLong = false
    private(set) var breakElapsedSeconds = 0
    let configuration: BreakTimerConfiguration

    init(configuration: BreakTimerConfiguration = .default) {
        self.configuration = configuration
    }

    init(
        configuration: BreakTimerConfiguration = .default,
        state: State,
        shortBreaksSinceLongBreak: Int = 0,
        currentBreakIsLong: Bool = false,
        breakElapsedSeconds: Int = 0
    ) {
        self.configuration = configuration
        let cadence = max(configuration.longBreakEveryShortBreaks, 1)
        self.shortBreaksSinceLongBreak = min(max(shortBreaksSinceLongBreak, 0), max(cadence - 1, 0))
        self.currentBreakIsLong = currentBreakIsLong
        self.breakElapsedSeconds = max(breakElapsedSeconds, 0)
        self.state = Self.normalizedState(
            state,
            configuration: configuration,
            currentBreakIsLong: currentBreakIsLong
        )
        if mode != .takingBreak {
            self.currentBreakIsLong = false
            self.breakElapsedSeconds = 0
        }
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

    var isLongBreakActive: Bool {
        mode == .takingBreak && currentBreakIsLong
    }

    var shortBreaksUntilLongBreak: Int {
        let cadence = max(configuration.longBreakEveryShortBreaks, 1)
        return max(cadence - shortBreaksSinceLongBreak, 1)
    }

    var canSkipBreak: Bool {
        guard mode == .takingBreak else {
            return false
        }

        switch configuration.breakPolicyMode {
        case .skipAnytime:
            return true
        case .skipAfterDelay:
            return breakElapsedSeconds >= configuration.skipDelaySeconds
        case .lock:
            return false
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
                if shouldTakeLongBreakNext() {
                    state = .takingBreak(remaining: configuration.longBreakDurationSeconds)
                    shortBreaksSinceLongBreak = 0
                    currentBreakIsLong = true
                } else {
                    state = .takingBreak(remaining: configuration.shortBreakDurationSeconds)
                    shortBreaksSinceLongBreak += 1
                    currentBreakIsLong = false
                }
                breakElapsedSeconds = 0
            }
            return true

        case let (.takingBreak(remaining), .tick):
            let next = remaining - 1
            if next > 0 {
                state = .takingBreak(remaining: next)
                breakElapsedSeconds += 1
            } else {
                state = .running(remaining: configuration.workDurationSeconds)
                currentBreakIsLong = false
                breakElapsedSeconds = 0
            }
            return true

        case (.running, .forceBreak), (.paused, .forceBreak):
            // Manual break should not advance long-break cadence.
            state = .takingBreak(remaining: configuration.shortBreakDurationSeconds)
            currentBreakIsLong = false
            breakElapsedSeconds = 0
            return true

        case (.takingBreak, .skipBreak) where canSkipBreak:
            state = .running(remaining: configuration.workDurationSeconds)
            currentBreakIsLong = false
            breakElapsedSeconds = 0
            return true

        case (.takingBreak, .dismissBreak):
            state = .running(remaining: configuration.workDurationSeconds)
            currentBreakIsLong = false
            breakElapsedSeconds = 0
            return true

        case (.idle, .reset), (.running, .reset), (.paused, .reset), (.takingBreak, .reset):
            state = .idle
            shortBreaksSinceLongBreak = 0
            currentBreakIsLong = false
            breakElapsedSeconds = 0
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
            return "takingBreak(\(remaining), long=\(currentBreakIsLong), elapsed=\(breakElapsedSeconds), shortsSinceLong=\(shortBreaksSinceLongBreak), policy=\(configuration.breakPolicyMode.rawValue))"
        }
    }

    private func shouldTakeLongBreakNext() -> Bool {
        let cadence = max(configuration.longBreakEveryShortBreaks, 1)
        return shortBreaksSinceLongBreak + 1 >= cadence
    }

    private static func normalizedState(
        _ state: State,
        configuration: BreakTimerConfiguration,
        currentBreakIsLong: Bool
    ) -> State {
        switch state {
        case .idle:
            return .idle
        case let .running(remaining):
            return .running(remaining: min(max(remaining, 1), max(configuration.workDurationSeconds, 1)))
        case let .paused(remaining):
            return .paused(remaining: min(max(remaining, 1), max(configuration.workDurationSeconds, 1)))
        case let .takingBreak(remaining):
            let breakMax = currentBreakIsLong ? configuration.longBreakDurationSeconds : configuration.shortBreakDurationSeconds
            return .takingBreak(remaining: min(max(remaining, 1), max(breakMax, 1)))
        }
    }
}
