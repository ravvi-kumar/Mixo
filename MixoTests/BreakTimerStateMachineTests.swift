import XCTest
@testable import Mixo

final class BreakTimerStateMachineTests: XCTestCase {
    func testStartTransitionsToRunning() {
        var machine = makeMachine(work: 5, rest: 2)

        XCTAssertTrue(machine.handle(.start))
        XCTAssertEqual(machine.state, .running(remaining: 5))
    }

    func testPauseResumeRoundTripPreservesRemaining() {
        var machine = makeMachine(work: 5, rest: 2)
        XCTAssertTrue(machine.handle(.start))
        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .running(remaining: 4))

        XCTAssertTrue(machine.handle(.pause))
        XCTAssertEqual(machine.state, .paused(remaining: 4))

        XCTAssertTrue(machine.handle(.resume))
        XCTAssertEqual(machine.state, .running(remaining: 4))
    }

    func testWorkToBreakAndBackToWorkTransitions() {
        var machine = makeMachine(work: 3, rest: 2)
        XCTAssertTrue(machine.handle(.start))

        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .running(remaining: 2))
        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .running(remaining: 1))

        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .takingBreak(remaining: 2))

        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .takingBreak(remaining: 1))

        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .running(remaining: 3))
    }

    func testForceBreakFromRunningAndPaused() {
        var runningMachine = makeMachine(work: 10, rest: 3)
        XCTAssertTrue(runningMachine.handle(.start))
        XCTAssertTrue(runningMachine.handle(.forceBreak))
        XCTAssertEqual(runningMachine.state, .takingBreak(remaining: 3))

        var pausedMachine = makeMachine(work: 10, rest: 3)
        XCTAssertTrue(pausedMachine.handle(.start))
        XCTAssertTrue(pausedMachine.handle(.tick))
        XCTAssertTrue(pausedMachine.handle(.pause))
        XCTAssertTrue(pausedMachine.handle(.forceBreak))
        XCTAssertEqual(pausedMachine.state, .takingBreak(remaining: 3))
    }

    func testDismissBreakReturnsToRunningCycle() {
        var machine = makeMachine(work: 10, rest: 3)
        XCTAssertTrue(machine.handle(.start))
        XCTAssertTrue(machine.handle(.forceBreak))
        XCTAssertEqual(machine.state, .takingBreak(remaining: 3))

        XCTAssertTrue(machine.handle(.dismissBreak))
        XCTAssertEqual(machine.state, .running(remaining: 10))
    }

    func testSkipAnytimeAllowsImmediateBreakSkip() {
        var machine = makeMachine(work: 10, rest: 5, policy: .skipAnytime)
        XCTAssertTrue(machine.handle(.start))
        XCTAssertTrue(machine.handle(.forceBreak))
        XCTAssertEqual(machine.state, .takingBreak(remaining: 5))
        XCTAssertTrue(machine.canSkipBreak)

        XCTAssertTrue(machine.handle(.skipBreak))
        XCTAssertEqual(machine.state, .running(remaining: 10))
        XCTAssertEqual(machine.breakElapsedSeconds, 0)
    }

    func testSkipAfterDelayBlocksUntilDelayElapses() {
        var machine = makeMachine(work: 10, rest: 5, policy: .skipAfterDelay, skipDelay: 2)
        XCTAssertTrue(machine.handle(.start))
        XCTAssertTrue(machine.handle(.forceBreak))
        XCTAssertEqual(machine.state, .takingBreak(remaining: 5))
        XCTAssertFalse(machine.canSkipBreak)
        XCTAssertFalse(machine.handle(.skipBreak))

        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .takingBreak(remaining: 4))
        XCTAssertEqual(machine.breakElapsedSeconds, 1)
        XCTAssertFalse(machine.canSkipBreak)
        XCTAssertFalse(machine.handle(.skipBreak))

        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .takingBreak(remaining: 3))
        XCTAssertEqual(machine.breakElapsedSeconds, 2)
        XCTAssertTrue(machine.canSkipBreak)
        XCTAssertTrue(machine.handle(.skipBreak))
        XCTAssertEqual(machine.state, .running(remaining: 10))
    }

    func testLockModeNeverAllowsSkipButAllowsEmergencyDismiss() {
        var machine = makeMachine(work: 10, rest: 5, policy: .lock)
        XCTAssertTrue(machine.handle(.start))
        XCTAssertTrue(machine.handle(.forceBreak))
        XCTAssertEqual(machine.state, .takingBreak(remaining: 5))

        XCTAssertFalse(machine.canSkipBreak)
        XCTAssertFalse(machine.handle(.skipBreak))
        XCTAssertTrue(machine.handle(.dismissBreak))
        XCTAssertEqual(machine.state, .running(remaining: 10))
    }

    func testDelayUpcomingBreakExtendsRunningOrPausedCountdown() {
        var runningMachine = makeMachine(work: 10, rest: 5)
        XCTAssertTrue(runningMachine.handle(.start))
        XCTAssertTrue(runningMachine.delayUpcomingBreak(by: 120))
        XCTAssertEqual(runningMachine.state, .running(remaining: 130))

        var pausedMachine = makeMachine(work: 10, rest: 5)
        XCTAssertTrue(pausedMachine.handle(.start))
        XCTAssertTrue(pausedMachine.handle(.pause))
        XCTAssertTrue(pausedMachine.delayUpcomingBreak(by: 90))
        XCTAssertEqual(pausedMachine.state, .paused(remaining: 100))

        var breakingMachine = makeMachine(work: 10, rest: 5)
        XCTAssertTrue(breakingMachine.handle(.start))
        XCTAssertTrue(breakingMachine.handle(.forceBreak))
        XCTAssertFalse(breakingMachine.delayUpcomingBreak(by: 60))
        XCTAssertEqual(breakingMachine.state, .takingBreak(remaining: 5))
    }

    func testLongBreakTriggersOnConfiguredCadence() {
        var machine = makeMachine(work: 2, rest: 3, longRest: 9, longEvery: 2)
        XCTAssertTrue(machine.handle(.start))

        // Work cycle 1 -> short break.
        XCTAssertTrue(machine.handle(.tick))
        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .takingBreak(remaining: 3))
        XCTAssertFalse(machine.isLongBreakActive)

        // Finish short break.
        XCTAssertTrue(machine.handle(.tick))
        XCTAssertTrue(machine.handle(.tick))
        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .running(remaining: 2))

        // Work cycle 2 -> long break.
        XCTAssertTrue(machine.handle(.tick))
        XCTAssertTrue(machine.handle(.tick))
        XCTAssertEqual(machine.state, .takingBreak(remaining: 9))
        XCTAssertTrue(machine.isLongBreakActive)
    }

    func testResetReturnsToIdleFromAnyState() {
        var running = makeMachine(work: 5, rest: 2)
        XCTAssertTrue(running.handle(.start))
        XCTAssertTrue(running.handle(.reset))
        XCTAssertEqual(running.state, .idle)

        var paused = makeMachine(work: 5, rest: 2)
        XCTAssertTrue(paused.handle(.start))
        XCTAssertTrue(paused.handle(.pause))
        XCTAssertTrue(paused.handle(.reset))
        XCTAssertEqual(paused.state, .idle)

        var breaking = makeMachine(work: 2, rest: 2)
        XCTAssertTrue(breaking.handle(.start))
        XCTAssertTrue(breaking.handle(.tick))
        XCTAssertTrue(breaking.handle(.tick))
        XCTAssertEqual(breaking.state, .takingBreak(remaining: 2))
        XCTAssertTrue(breaking.handle(.reset))
        XCTAssertEqual(breaking.state, .idle)
    }

    func testInvalidTransitionsAreIgnored() {
        var machine = makeMachine(work: 5, rest: 2)

        XCTAssertFalse(machine.handle(.pause))
        XCTAssertFalse(machine.handle(.resume))
        XCTAssertFalse(machine.handle(.tick))
        XCTAssertFalse(machine.handle(.forceBreak))
        XCTAssertEqual(machine.state, .idle)

        XCTAssertTrue(machine.handle(.start))
        XCTAssertFalse(machine.handle(.start))
        XCTAssertEqual(machine.state, .running(remaining: 5))

        XCTAssertTrue(machine.handle(.pause))
        XCTAssertFalse(machine.handle(.pause))
        XCTAssertEqual(machine.state, .paused(remaining: 5))
    }

    func testTwoHourSimulationHasNoCumulativeDrift() {
        let work = 20 * 60
        let rest = 20
        let twoHours = 2 * 60 * 60
        let cycleLength = work + rest

        var machine = makeMachine(work: work, rest: rest, longRest: 120, longEvery: 1000)
        XCTAssertTrue(machine.handle(.start))

        for _ in 0..<twoHours {
            XCTAssertTrue(machine.handle(.tick))
        }

        let completedCycles = twoHours / cycleLength
        let remainder = twoHours % cycleLength

        // A cycle ends in running(work). Remaining ticks reduce running countdown.
        let expectedRemaining = work - remainder
        XCTAssertEqual(completedCycles, 5)
        XCTAssertEqual(machine.state, .running(remaining: expectedRemaining))
        XCTAssertEqual(machine.state, .running(remaining: 100))
    }

    func testWorkHoursWindowSameDayRange() {
        let calendar = makeCalendar()
        let configuration = BreakTimerConfiguration(
            workDurationSeconds: 1200,
            breakDurationSeconds: 20,
            workHoursEnabled: true,
            workdayStartMinutes: 9 * 60,
            workdayEndMinutes: 17 * 60
        )

        XCTAssertFalse(configuration.isWithinWorkHours(at: makeDate(hour: 8, minute: 59, calendar: calendar), calendar: calendar))
        XCTAssertTrue(configuration.isWithinWorkHours(at: makeDate(hour: 9, minute: 0, calendar: calendar), calendar: calendar))
        XCTAssertTrue(configuration.isWithinWorkHours(at: makeDate(hour: 16, minute: 59, calendar: calendar), calendar: calendar))
        XCTAssertFalse(configuration.isWithinWorkHours(at: makeDate(hour: 17, minute: 0, calendar: calendar), calendar: calendar))
    }

    func testWorkHoursWindowOvernightRange() {
        let calendar = makeCalendar()
        let configuration = BreakTimerConfiguration(
            workDurationSeconds: 1200,
            breakDurationSeconds: 20,
            workHoursEnabled: true,
            workdayStartMinutes: 22 * 60,
            workdayEndMinutes: 6 * 60
        )

        XCTAssertFalse(configuration.isWithinWorkHours(at: makeDate(hour: 21, minute: 30, calendar: calendar), calendar: calendar))
        XCTAssertTrue(configuration.isWithinWorkHours(at: makeDate(hour: 22, minute: 0, calendar: calendar), calendar: calendar))
        XCTAssertTrue(configuration.isWithinWorkHours(at: makeDate(hour: 2, minute: 0, calendar: calendar), calendar: calendar))
        XCTAssertFalse(configuration.isWithinWorkHours(at: makeDate(hour: 6, minute: 0, calendar: calendar), calendar: calendar))
    }

    private func makeMachine(
        work: Int,
        rest: Int,
        longRest: Int = 120,
        longEvery: Int = 4,
        policy: BreakPolicyMode = .skipAnytime,
        skipDelay: Int = 10
    ) -> BreakTimerStateMachine {
        BreakTimerStateMachine(
            configuration: BreakTimerConfiguration(
                workDurationSeconds: work,
                breakDurationSeconds: rest,
                longBreakDurationSeconds: longRest,
                longBreakEveryShortBreaks: longEvery,
                breakPolicyMode: policy,
                skipDelaySeconds: skipDelay
            )
        )
    }

    private func makeDate(hour: Int, minute: Int, calendar: Calendar) -> Date {
        return calendar.date(from: DateComponents(year: 2026, month: 3, day: 27, hour: hour, minute: minute))!
    }

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
}
