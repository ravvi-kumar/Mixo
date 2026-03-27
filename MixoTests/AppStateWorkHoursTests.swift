import XCTest
@testable import Mixo

@MainActor
final class AppStateWorkHoursTests: XCTestCase {
    func testStartBlockedOutsideConfiguredWorkHours() {
        let appState = makeAppState()

        appState.startTimer(now: makeDate(hour: 7, minute: 30))

        XCTAssertEqual(appState.timerMode, .idle)
        XCTAssertEqual(appState.lastActionMessage, "Start unavailable outside configured work hours")
    }

    func testStartAllowedInsideConfiguredWorkHours() {
        let appState = makeAppState()

        appState.startTimer(now: makeDate(hour: 10, minute: 0))

        XCTAssertEqual(appState.timerMode, .running)
    }

    func testRunningTimerAutoPausesOutsideWindowAndResumesInsideWindow() {
        let appState = makeAppState()
        appState.startTimer(now: makeDate(hour: 9, minute: 15))
        XCTAssertEqual(appState.timerMode, .running)

        let paused = appState.processWorkHoursScheduleSample(now: makeDate(hour: 18, minute: 0))
        XCTAssertTrue(paused)
        XCTAssertEqual(appState.timerMode, .paused)
        XCTAssertEqual(appState.lastActionMessage, "Timer paused outside configured work hours")

        let resumed = appState.processWorkHoursScheduleSample(now: makeDate(hour: 9, minute: 30))
        XCTAssertTrue(resumed)
        XCTAssertEqual(appState.timerMode, .running)
        XCTAssertEqual(appState.lastActionMessage, "Timer resumed within configured work hours")
    }

    private func makeAppState() -> AppState {
        let suiteName = "mixo.appstate.work-hours.tests.\(UUID().uuidString)"
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
                workDurationSeconds: 300,
                breakDurationSeconds: 20,
                workHoursEnabled: true,
                workdayStartMinutes: 9 * 60,
                workdayEndMinutes: 17 * 60
            )
        )
    }

    private func makeDate(hour: Int, minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar.date(from: DateComponents(year: 2026, month: 3, day: 27, hour: hour, minute: minute))!
    }
}
