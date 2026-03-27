import XCTest
@testable import Mixo

@MainActor
final class AppStateFullscreenDeferralTests: XCTestCase {
    func testPendingBreakDefersUntilFullscreenEnds() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let fullscreenService = FullscreenActivityServiceStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: IdleActivityServiceStub(),
            fullscreenActivityService: fullscreenService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 3,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 0,
                longIdleResetThresholdSeconds: 0
            )
        )

        appState.startTimer()
        XCTAssertEqual(appState.timerMode, .running)
        XCTAssertEqual(appState.timerRemainingSeconds, 3)

        XCTAssertTrue(appState.processTimerTick())
        XCTAssertEqual(appState.timerMode, .running)
        XCTAssertEqual(appState.timerRemainingSeconds, 2)

        fullscreenService.isActive = true
        XCTAssertTrue(appState.processTimerTick())
        XCTAssertEqual(appState.timerMode, .running)
        XCTAssertEqual(appState.timerRemainingSeconds, 1)

        XCTAssertFalse(appState.processTimerTick())
        XCTAssertEqual(appState.timerMode, .running)
        XCTAssertEqual(appState.timerRemainingSeconds, 1)
        XCTAssertEqual(appState.lastActionMessage, "Break deferred while fullscreen is active")

        fullscreenService.isActive = false
        XCTAssertTrue(appState.processTimerTick())
        XCTAssertEqual(appState.timerMode, .takingBreak)
        XCTAssertEqual(appState.timerRemainingSeconds, 20)
    }

    func testTakeBreakNowBypassesFullscreenDeferralGate() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let fullscreenService = FullscreenActivityServiceStub()
        fullscreenService.isActive = true
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: IdleActivityServiceStub(),
            fullscreenActivityService: fullscreenService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 60,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 0,
                longIdleResetThresholdSeconds: 0
            )
        )

        appState.startTimer()
        appState.takeBreakNow()
        XCTAssertEqual(appState.timerMode, .takingBreak)
        XCTAssertEqual(appState.timerRemainingSeconds, 20)
        XCTAssertEqual(appState.lastActionMessage, "Break started")
    }

    private func makeDefaults() -> (UserDefaults, String) {
        let suiteName = "mixo.appstate.fullscreen.tests.\(UUID().uuidString)"
        return (UserDefaults(suiteName: suiteName)!, suiteName)
    }
}

private struct IdleActivityServiceStub: IdleActivityServicing {
    func idleDurationSeconds() -> TimeInterval {
        0
    }
}

private final class FullscreenActivityServiceStub: FullscreenActivityServicing {
    var isActive = false

    func isFullscreenActive() -> Bool {
        isActive
    }
}
