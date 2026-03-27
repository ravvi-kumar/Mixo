import XCTest
@testable import Mixo

@MainActor
final class AppStateSmartPauseTests: XCTestCase {
    func testIdleSamplePausesRunningTimerWhenThresholdReached() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let idleService = IdleActivityServiceStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: idleService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 120,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 5
            )
        )

        appState.startTimer()
        XCTAssertEqual(appState.timerMode, .running)

        let pauseSampleTime = Date().addingTimeInterval(5)
        XCTAssertTrue(appState.processIdleActivitySample(idleSeconds: 5, now: pauseSampleTime))
        XCTAssertEqual(appState.timerMode, .paused)
        XCTAssertEqual(appState.smartPauseReasonDisplay, "Idle")
        XCTAssertEqual(appState.lastActionMessage, "Timer auto-paused while idle")

        appState.resetTimer()
    }

    func testIdleSampleResumesTimerAfterAutoPauseWhenActivityReturns() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let idleService = IdleActivityServiceStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: idleService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 120,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 5
            )
        )

        appState.startTimer()
        let pauseSampleTime = Date().addingTimeInterval(8)
        XCTAssertTrue(appState.processIdleActivitySample(idleSeconds: 8, now: pauseSampleTime))
        XCTAssertEqual(appState.timerMode, .paused)

        XCTAssertTrue(appState.processIdleActivitySample(idleSeconds: 0, now: pauseSampleTime.addingTimeInterval(1)))
        XCTAssertEqual(appState.timerMode, .running)
        XCTAssertEqual(appState.smartPauseReasonDisplay, "None")
        XCTAssertEqual(appState.lastActionMessage, "Timer resumed after activity")

        appState.resetTimer()
    }

    func testManualPauseDoesNotAutoResumeOnActivitySample() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let idleService = IdleActivityServiceStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: idleService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 120,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 5
            )
        )

        appState.startTimer()
        appState.pauseTimer()
        XCTAssertEqual(appState.timerMode, .paused)

        XCTAssertFalse(appState.processIdleActivitySample(idleSeconds: 0, now: Date().addingTimeInterval(5)))
        XCTAssertEqual(appState.timerMode, .paused)

        appState.resetTimer()
    }

    func testReportedHistoricalIdleDoesNotTriggerImmediatePauseAfterStart() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let idleService = IdleActivityServiceStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: idleService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 120,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 10
            )
        )

        appState.startTimer()
        XCTAssertEqual(appState.timerMode, .running)

        let oneSecondAfterStart = Date().addingTimeInterval(1)
        XCTAssertFalse(appState.processIdleActivitySample(idleSeconds: 3500, now: oneSecondAfterStart))
        XCTAssertEqual(appState.timerMode, .running)

        let tenSecondsAfterStart = Date().addingTimeInterval(10)
        XCTAssertTrue(appState.processIdleActivitySample(idleSeconds: 3500, now: tenSecondsAfterStart))
        XCTAssertEqual(appState.timerMode, .paused)

        appState.resetTimer()
    }

    func testLongIdleResetsCycleAfterAutoPauseThreshold() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let idleService = IdleActivityServiceStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: idleService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 120,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 5,
                longIdleResetThresholdSeconds: 20
            )
        )

        appState.startTimer()
        XCTAssertTrue(appState.processIdleActivitySample(idleSeconds: 5, now: Date().addingTimeInterval(5)))
        XCTAssertEqual(appState.timerMode, .paused)

        XCTAssertFalse(appState.processIdleActivitySample(idleSeconds: 19, now: Date().addingTimeInterval(19)))
        XCTAssertEqual(appState.timerMode, .paused)

        XCTAssertTrue(appState.processIdleActivitySample(idleSeconds: 20, now: Date().addingTimeInterval(20)))
        XCTAssertEqual(appState.timerMode, .idle)
        XCTAssertEqual(appState.smartPauseReasonDisplay, "None")
        XCTAssertEqual(appState.lastActionMessage, "Timer reset after long idle")
    }

    func testLongIdleCanResetRunningTimerWhenPauseThresholdDisabled() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let idleService = IdleActivityServiceStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: idleService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 120,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 0,
                longIdleResetThresholdSeconds: 10
            )
        )

        appState.startTimer()
        XCTAssertEqual(appState.timerMode, .running)

        XCTAssertTrue(appState.processIdleActivitySample(idleSeconds: 10, now: Date().addingTimeInterval(10)))
        XCTAssertEqual(appState.timerMode, .idle)
        XCTAssertEqual(appState.smartPauseReasonDisplay, "None")
        XCTAssertEqual(appState.lastActionMessage, "Timer reset after long idle")
    }

    func testManualPauseDoesNotTriggerLongIdleAutoReset() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let idleService = IdleActivityServiceStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            idleActivityService: idleService,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 120,
                breakDurationSeconds: 20,
                idlePauseThresholdSeconds: 5,
                longIdleResetThresholdSeconds: 10
            )
        )

        appState.startTimer()
        appState.pauseTimer()
        XCTAssertEqual(appState.timerMode, .paused)

        XCTAssertFalse(appState.processIdleActivitySample(idleSeconds: 50, now: Date().addingTimeInterval(50)))
        XCTAssertEqual(appState.timerMode, .paused)

        appState.resetTimer()
    }

    private func makeDefaults() -> (UserDefaults, String) {
        let suiteName = "mixo.appstate.smartpause.tests.\(UUID().uuidString)"
        return (UserDefaults(suiteName: suiteName)!, suiteName)
    }
}

private final class IdleActivityServiceStub: IdleActivityServicing {
    func idleDurationSeconds() -> TimeInterval {
        0
    }
}
