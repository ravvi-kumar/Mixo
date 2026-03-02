import XCTest
@testable import Mixo

@MainActor
final class AppStateBreakChimeTests: XCTestCase {
    func testBreakStartAndEndChimePlayOnBreakCycle() {
        let suiteName = "mixo.appstate.breakchime.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let chimeSpy = BreakChimeSpy()

        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            breakChimeService: chimeSpy,
            timerConfiguration: BreakTimerConfiguration(workDurationSeconds: 90, breakDurationSeconds: 20)
        )

        appState.startTimer()
        appState.takeBreakNow()
        XCTAssertEqual(chimeSpy.startCount, 1)
        XCTAssertEqual(chimeSpy.endCount, 0)

        appState.skipBreak()
        XCTAssertEqual(chimeSpy.startCount, 1)
        XCTAssertEqual(chimeSpy.endCount, 1)

        appState.resetTimer()
    }
}

@MainActor
private final class BreakChimeSpy: BreakChimePlaying {
    private(set) var startCount = 0
    private(set) var endCount = 0

    func playBreakStartChime() {
        startCount += 1
    }

    func playBreakEndChime() {
        endCount += 1
    }
}
