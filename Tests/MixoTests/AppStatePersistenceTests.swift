import XCTest
@testable import Mixo

final class AppStatePersistenceTests: XCTestCase {
    @MainActor
    func testAppStateRestoresPersistedPausedTimer() {
        let suiteName = "mixo.appstate.persistence.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let key = "timer.snapshot.test"
        let persistence = TimerPersistenceService(defaults: defaults, key: key)
        let savedConfiguration = BreakTimerConfiguration(workDurationSeconds: 25 * 60, breakDurationSeconds: 45)
        persistence.save(configuration: savedConfiguration, state: .paused(remaining: 777))

        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            timerConfiguration: .default
        )

        XCTAssertEqual(appState.timerMode, .paused)
        XCTAssertEqual(appState.timerRemainingSeconds, 777)
        XCTAssertEqual(appState.timerWorkDurationMinutes, 25)
        XCTAssertEqual(appState.timerBreakDurationSeconds, 45)
    }

    @MainActor
    func testAppStatePersistsStateAfterTimerStart() {
        let suiteName = "mixo.appstate.persistence.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let key = "timer.snapshot.test"
        let persistence = TimerPersistenceService(defaults: defaults, key: key)

        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            timerConfiguration: BreakTimerConfiguration(workDurationSeconds: 90, breakDurationSeconds: 15)
        )
        appState.startTimer()

        let snapshot = persistence.load()
        XCTAssertEqual(snapshot?.configuration, BreakTimerConfiguration(workDurationSeconds: 90, breakDurationSeconds: 15))
        XCTAssertEqual(snapshot?.state, .running(remaining: 90))

        appState.resetTimer()
    }
}
