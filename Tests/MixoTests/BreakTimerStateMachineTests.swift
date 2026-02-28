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

        var machine = makeMachine(work: work, rest: rest)
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

    private func makeMachine(work: Int, rest: Int) -> BreakTimerStateMachine {
        BreakTimerStateMachine(
            configuration: BreakTimerConfiguration(
                workDurationSeconds: work,
                breakDurationSeconds: rest
            )
        )
    }
}
