import XCTest
@testable import Mixo

final class TimerPersistenceServiceTests: XCTestCase {
    func testSaveAndLoadRoundTripForRunningState() {
        let (defaults, suiteName) = makeDefaults()
        defer { clearDefaults(named: suiteName) }

        let service = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let configuration = BreakTimerConfiguration(workDurationSeconds: 1200, breakDurationSeconds: 20)
        let machine = BreakTimerStateMachine(
            configuration: configuration,
            state: .running(remaining: 845),
            shortBreaksSinceLongBreak: 2,
            currentBreakIsLong: false
        )

        service.save(machine: machine)
        let snapshot = service.load()

        XCTAssertEqual(snapshot?.configuration, configuration)
        XCTAssertEqual(snapshot?.state, .running(remaining: 845))
        XCTAssertEqual(snapshot?.shortBreaksSinceLongBreak, 2)
        XCTAssertEqual(snapshot?.currentBreakIsLong, false)
    }

    func testLoadReturnsNilWhenSnapshotMissing() {
        let (defaults, suiteName) = makeDefaults()
        defer { clearDefaults(named: suiteName) }

        let service = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        XCTAssertNil(service.load())
    }

    func testLoadRemovesCorruptSnapshot() {
        let (defaults, suiteName) = makeDefaults()
        defer { clearDefaults(named: suiteName) }

        let key = "timer.snapshot.test"
        defaults.set(Data("not-json".utf8), forKey: key)

        let service = TimerPersistenceService(defaults: defaults, key: key)
        XCTAssertNil(service.load())
        XCTAssertNil(defaults.data(forKey: key))
    }

    func testSaveAndLoadRoundTripForBreakStateWithPolicyMetadata() {
        let (defaults, suiteName) = makeDefaults()
        defer { clearDefaults(named: suiteName) }

        let service = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let configuration = BreakTimerConfiguration(
            workDurationSeconds: 1800,
            breakDurationSeconds: 30,
            longBreakDurationSeconds: 300,
            longBreakEveryShortBreaks: 3,
            breakPolicyMode: .skipAfterDelay,
            skipDelaySeconds: 25
        )
        let machine = BreakTimerStateMachine(
            configuration: configuration,
            state: .takingBreak(remaining: 240),
            shortBreaksSinceLongBreak: 2,
            currentBreakIsLong: true,
            breakElapsedSeconds: 17
        )

        service.save(machine: machine)
        let snapshot = service.load()

        XCTAssertEqual(snapshot?.configuration, configuration)
        XCTAssertEqual(snapshot?.state, .takingBreak(remaining: 240))
        XCTAssertEqual(snapshot?.shortBreaksSinceLongBreak, 2)
        XCTAssertEqual(snapshot?.currentBreakIsLong, true)
        XCTAssertEqual(snapshot?.breakElapsedSeconds, 17)
    }

    private func makeDefaults() -> (UserDefaults, String) {
        let suiteName = "mixo.timer.persistence.tests.\(UUID().uuidString)"
        // Force-unwrap is safe here because suite names are generated and valid.
        return (UserDefaults(suiteName: suiteName)!, suiteName)
    }

    private func clearDefaults(named suiteName: String) {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return
        }
        defaults.removePersistentDomain(forName: suiteName)
    }
}
