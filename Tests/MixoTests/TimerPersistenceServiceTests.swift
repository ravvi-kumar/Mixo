import XCTest
@testable import Mixo

final class TimerPersistenceServiceTests: XCTestCase {
    func testSaveAndLoadRoundTripForRunningState() {
        let (defaults, suiteName) = makeDefaults()
        defer { clearDefaults(named: suiteName) }

        let service = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let configuration = BreakTimerConfiguration(workDurationSeconds: 1200, breakDurationSeconds: 20)
        let state = BreakTimerStateMachine.State.running(remaining: 845)

        service.save(configuration: configuration, state: state)
        let snapshot = service.load()

        XCTAssertEqual(snapshot?.configuration, configuration)
        XCTAssertEqual(snapshot?.state, state)
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
