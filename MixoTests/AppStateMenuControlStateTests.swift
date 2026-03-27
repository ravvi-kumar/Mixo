import XCTest
@testable import Mixo

@MainActor
final class AppStateMenuControlStateTests: XCTestCase {
    func testMenuControlFlagsTrackIdleRunningPausedStates() {
        let appState = makeAppState()

        XCTAssertTrue(appState.canStartTimer)
        XCTAssertFalse(appState.canPauseTimer)
        XCTAssertFalse(appState.canResumeTimer)
        XCTAssertFalse(appState.canTakeBreakNow)
        XCTAssertFalse(appState.canResetTimer)

        appState.startTimer()
        XCTAssertFalse(appState.canStartTimer)
        XCTAssertTrue(appState.canPauseTimer)
        XCTAssertFalse(appState.canResumeTimer)
        XCTAssertTrue(appState.canTakeBreakNow)
        XCTAssertTrue(appState.canResetTimer)

        appState.pauseTimer()
        XCTAssertFalse(appState.canStartTimer)
        XCTAssertFalse(appState.canPauseTimer)
        XCTAssertTrue(appState.canResumeTimer)
        XCTAssertTrue(appState.canTakeBreakNow)
        XCTAssertTrue(appState.canResetTimer)

        appState.resetTimer()
        XCTAssertTrue(appState.canStartTimer)
        XCTAssertFalse(appState.canPauseTimer)
        XCTAssertFalse(appState.canResumeTimer)
        XCTAssertFalse(appState.canTakeBreakNow)
        XCTAssertFalse(appState.canResetTimer)
    }

    func testSkipBreakControlHiddenInLockPolicyBreak() {
        let appState = makeAppState(policy: .lock)

        appState.startTimer()
        appState.takeBreakNow()

        XCTAssertEqual(appState.timerMode, .takingBreak)
        XCTAssertFalse(appState.shouldShowSkipBreakAction)
        XCTAssertFalse(appState.canSkipBreak)
    }

    func testSkipBreakControlVisibleInSkipAnytimeBreak() {
        let appState = makeAppState(policy: .skipAnytime)

        appState.startTimer()
        appState.takeBreakNow()

        XCTAssertEqual(appState.timerMode, .takingBreak)
        XCTAssertTrue(appState.shouldShowSkipBreakAction)
        XCTAssertTrue(appState.canSkipBreak)
    }

    private func makeAppState(policy: BreakPolicyMode = .skipAnytime) -> AppState {
        let suiteName = "mixo.appstate.menu-control.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        addTeardownBlock {
            defaults.removePersistentDomain(forName: suiteName)
        }
        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let shortcutPersistence = ShortcutPersistenceService(defaults: defaults, key: "shortcut.bindings.test")

        return AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            shortcutPersistenceService: shortcutPersistence,
            enableGlobalShortcuts: false,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 60,
                breakDurationSeconds: 20,
                longBreakDurationSeconds: 120,
                longBreakEveryShortBreaks: 4,
                breakPolicyMode: policy,
                skipDelaySeconds: 10,
                preBreakNotificationLeadTimeSeconds: 30,
                idlePauseThresholdSeconds: 120,
                longIdleResetThresholdSeconds: 900
            )
        )
    }
}
