import XCTest
@testable import Mixo

@MainActor
final class AppStateMediaDeferralTests: XCTestCase {
    func testPendingBreakDefersUntilMediaPlaybackStops() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let fullscreenService = FullscreenActivityServiceStub()
        let mediaService = MediaActivityServiceStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: IdleActivityServiceStub(),
            fullscreenActivityService: fullscreenService,
            mediaActivityService: mediaService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 3,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 0,
                longIdleResetThresholdSeconds: 0
            )
        )

        appState.startTimer()
        XCTAssertTrue(appState.processTimerTick())
        XCTAssertEqual(appState.timerRemainingSeconds, 2)

        mediaService.isActive = true
        XCTAssertTrue(appState.processTimerTick())
        XCTAssertEqual(appState.timerRemainingSeconds, 1)

        XCTAssertFalse(appState.processTimerTick())
        XCTAssertEqual(appState.timerMode, .running)
        XCTAssertEqual(appState.timerRemainingSeconds, 1)
        XCTAssertEqual(appState.smartPauseReasonDisplay, "Media Playback")
        XCTAssertEqual(appState.lastActionMessage, "Break deferred while media playback is active")

        mediaService.isActive = false
        XCTAssertTrue(appState.processTimerTick())
        XCTAssertEqual(appState.timerMode, .takingBreak)
        XCTAssertEqual(appState.timerRemainingSeconds, 20)
        XCTAssertEqual(appState.smartPauseReasonDisplay, "None")
    }

    func testFullscreenDeferralTakesPriorityOverMedia() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let fullscreenService = FullscreenActivityServiceStub()
        let mediaService = MediaActivityServiceStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: IdleActivityServiceStub(),
            fullscreenActivityService: fullscreenService,
            mediaActivityService: mediaService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 3,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 0,
                longIdleResetThresholdSeconds: 0
            )
        )

        appState.startTimer()
        XCTAssertTrue(appState.processTimerTick())
        XCTAssertEqual(appState.timerRemainingSeconds, 2)

        fullscreenService.isActive = true
        mediaService.isActive = true
        XCTAssertTrue(appState.processTimerTick())
        XCTAssertEqual(appState.timerRemainingSeconds, 1)

        XCTAssertFalse(appState.processTimerTick())
        XCTAssertEqual(appState.smartPauseReasonDisplay, "Fullscreen")
        XCTAssertEqual(appState.lastActionMessage, "Break deferred while fullscreen is active")

        fullscreenService.isActive = false
        XCTAssertFalse(appState.processTimerTick())
        XCTAssertEqual(appState.smartPauseReasonDisplay, "Media Playback")
        XCTAssertEqual(appState.lastActionMessage, "Break deferred while media playback is active")

        mediaService.isActive = false
        XCTAssertTrue(appState.processTimerTick())
        XCTAssertEqual(appState.timerMode, .takingBreak)
        XCTAssertEqual(appState.smartPauseReasonDisplay, "None")
    }

    func testTakeBreakNowBypassesMediaDeferralGate() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let fullscreenService = FullscreenActivityServiceStub()
        let mediaService = MediaActivityServiceStub()
        mediaService.isActive = true
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: IdleActivityServiceStub(),
            fullscreenActivityService: fullscreenService,
            mediaActivityService: mediaService,
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
    }

    private func makeDefaults() -> (UserDefaults, String) {
        let suiteName = "mixo.appstate.media.tests.\(UUID().uuidString)"
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

private final class MediaActivityServiceStub: MediaActivityServicing {
    var isActive = false

    func isMediaPlaybackLikelyActive() -> Bool {
        isActive
    }
}
