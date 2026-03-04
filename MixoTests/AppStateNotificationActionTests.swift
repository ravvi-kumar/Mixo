import XCTest
@testable import Mixo

@MainActor
final class AppStateNotificationActionTests: XCTestCase {
    func testStartNowActionForcesImmediateBreak() {
        let suiteName = "mixo.appstate.notificationaction.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            timerConfiguration: BreakTimerConfiguration(workDurationSeconds: 90, breakDurationSeconds: 20)
        )

        appState.startTimer()
        XCTAssertEqual(appState.timerMode, .running)

        appState.handleHeadsUpAction(.startNow)
        XCTAssertEqual(appState.timerMode, .takingBreak)
        XCTAssertEqual(appState.lastActionMessage, "Break started from notification action")

        appState.resetTimer()
    }

    func testDelayActionExtendsUpcomingBreakCountdown() {
        let suiteName = "mixo.appstate.notificationaction.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            timerConfiguration: BreakTimerConfiguration(workDurationSeconds: 90, breakDurationSeconds: 20)
        )

        appState.startTimer()
        let beforeDelay = appState.timerRemainingSeconds
        appState.handleHeadsUpAction(.delay, delaySeconds: 120)

        XCTAssertEqual(appState.timerMode, .running)
        XCTAssertEqual(appState.timerRemainingSeconds, beforeDelay + 120)
        XCTAssertEqual(appState.lastActionMessage, "Break delayed by 2 min from notification")

        appState.resetTimer()
    }

    func testDelayActionIgnoredDuringActiveBreak() {
        let suiteName = "mixo.appstate.notificationaction.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            timerConfiguration: BreakTimerConfiguration(workDurationSeconds: 90, breakDurationSeconds: 20)
        )

        appState.startTimer()
        appState.takeBreakNow()
        XCTAssertEqual(appState.timerMode, .takingBreak)

        let breakRemaining = appState.timerRemainingSeconds
        appState.handleHeadsUpAction(.delay, delaySeconds: 120)
        XCTAssertEqual(appState.timerMode, .takingBreak)
        XCTAssertEqual(appState.timerRemainingSeconds, breakRemaining)
        XCTAssertEqual(appState.lastActionMessage, "Notification delay ignored in current state")

        appState.resetTimer()
    }
}
