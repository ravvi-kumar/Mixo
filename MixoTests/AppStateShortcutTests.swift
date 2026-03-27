import Carbon.HIToolbox
import XCTest
@testable import Mixo

@MainActor
final class AppStateShortcutTests: XCTestCase {
    func testStartShortcutStartsIdleTimer() async {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let shortcutPersistence = ShortcutPersistenceService(defaults: defaults, key: "shortcut.bindings.test")
        let shortcutManager = ShortcutManagerStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            shortcutPersistenceService: shortcutPersistence,
            shortcutManager: shortcutManager,
            enableGlobalShortcuts: true,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 60,
                breakDurationSeconds: 20
            )
        )

        XCTAssertEqual(shortcutManager.startCalls, 1)
        XCTAssertEqual(appState.timerMode, .idle)

        shortcutManager.trigger(.start)
        await Task.yield()

        XCTAssertEqual(appState.timerMode, .running)
        XCTAssertEqual(appState.timerRemainingSeconds, 60)
    }

    func testPauseResumeShortcutTogglesRunningState() async {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let shortcutPersistence = ShortcutPersistenceService(defaults: defaults, key: "shortcut.bindings.test")
        let shortcutManager = ShortcutManagerStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            shortcutPersistenceService: shortcutPersistence,
            shortcutManager: shortcutManager,
            enableGlobalShortcuts: true,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 60,
                breakDurationSeconds: 20
            )
        )

        shortcutManager.trigger(.start)
        await Task.yield()
        XCTAssertEqual(appState.timerMode, .running)

        shortcutManager.trigger(.pauseResume)
        await Task.yield()
        XCTAssertEqual(appState.timerMode, .paused)

        shortcutManager.trigger(.pauseResume)
        await Task.yield()
        XCTAssertEqual(appState.timerMode, .running)
    }

    func testSkipShortcutSkipsActiveBreak() async {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let shortcutPersistence = ShortcutPersistenceService(defaults: defaults, key: "shortcut.bindings.test")
        let shortcutManager = ShortcutManagerStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            shortcutPersistenceService: shortcutPersistence,
            shortcutManager: shortcutManager,
            enableGlobalShortcuts: true,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 60,
                breakDurationSeconds: 20
            )
        )

        appState.startTimer()
        appState.takeBreakNow()
        XCTAssertEqual(appState.timerMode, .takingBreak)

        shortcutManager.trigger(.skipBreak)
        await Task.yield()

        XCTAssertEqual(appState.timerMode, .running)
    }

    func testShortcutRegistrationDefaultsDisabledUnderTests() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let shortcutPersistence = ShortcutPersistenceService(defaults: defaults, key: "shortcut.bindings.test")
        let shortcutManager = ShortcutManagerStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            shortcutPersistenceService: shortcutPersistence,
            shortcutManager: shortcutManager,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 60,
                breakDurationSeconds: 20
            )
        )

        XCTAssertEqual(shortcutManager.startCalls, 0)
        XCTAssertEqual(appState.globalShortcutsStatusDisplay, "Disabled")
    }

    func testCustomShortcutBindingsLoadAndRegisterOnStartup() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let shortcutPersistence = ShortcutPersistenceService(defaults: defaults, key: "shortcut.bindings.test")
        let customStartBinding = ShortcutBinding(
            keyCode: UInt32(kVK_ANSI_R),
            carbonModifiers: UInt32(cmdKey | optionKey),
            display: "Option+Command+R"
        )
        shortcutPersistence.save([.start: customStartBinding])

        let shortcutManager = ShortcutManagerStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            shortcutPersistenceService: shortcutPersistence,
            shortcutManager: shortcutManager,
            enableGlobalShortcuts: true,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 60,
                breakDurationSeconds: 20
            )
        )

        XCTAssertEqual(appState.shortcutBindingDisplay(for: .start), customStartBinding.display)
        XCTAssertEqual(shortcutManager.lastBindings[.start], customStartBinding)
    }

    func testUpdatingShortcutBindingPersistsAndReRegistersManager() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let shortcutPersistence = ShortcutPersistenceService(defaults: defaults, key: "shortcut.bindings.test")
        let shortcutManager = ShortcutManagerStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            shortcutPersistenceService: shortcutPersistence,
            shortcutManager: shortcutManager,
            enableGlobalShortcuts: true,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 60,
                breakDurationSeconds: 20
            )
        )

        let binding = ShortcutBinding(
            keyCode: UInt32(kVK_ANSI_L),
            carbonModifiers: UInt32(controlKey | optionKey),
            display: "Control+Option+L"
        )
        let result = appState.updateShortcutBinding(binding, for: .pauseResume)

        XCTAssertEqual(result, .updated)
        XCTAssertEqual(shortcutManager.startCalls, 2)
        XCTAssertEqual(shortcutManager.lastBindings[.pauseResume], binding)
        XCTAssertEqual(shortcutPersistence.load()[.pauseResume], binding)
    }

    func testUpdatingShortcutBindingRejectsInternalConflict() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let persistence = TimerPersistenceService(defaults: defaults, key: "timer.snapshot.test")
        let shortcutPersistence = ShortcutPersistenceService(defaults: defaults, key: "shortcut.bindings.test")
        let shortcutManager = ShortcutManagerStub()
        let appState = AppState(
            notificationService: .init(),
            timerPersistenceService: persistence,
            shortcutPersistenceService: shortcutPersistence,
            shortcutManager: shortcutManager,
            enableGlobalShortcuts: true,
            timerConfiguration: BreakTimerConfiguration(
                workDurationSeconds: 60,
                breakDurationSeconds: 20
            )
        )

        let conflictBinding = appState.shortcutBindings[.start]!
        let result = appState.updateShortcutBinding(conflictBinding, for: .pauseResume)

        XCTAssertEqual(result, .conflict(existingAction: .start))
        XCTAssertEqual(appState.shortcutBindingDisplay(for: .pauseResume), ShortcutAction.pauseResume.defaultBinding.display)
        XCTAssertEqual(shortcutManager.startCalls, 1)
        XCTAssertTrue(shortcutPersistence.load().isEmpty)
    }

    private func makeDefaults() -> (UserDefaults, String) {
        let suiteName = "mixo.appstate.shortcuts.tests.\(UUID().uuidString)"
        return (UserDefaults(suiteName: suiteName)!, suiteName)
    }
}

private final class ShortcutManagerStub: ShortcutManaging {
    private var handler: ((ShortcutAction) -> Void)?
    private(set) var startCalls = 0
    private(set) var stopCalls = 0
    private(set) var lastBindings: [ShortcutAction: ShortcutBinding] = [:]

    func start(
        bindings: [ShortcutAction: ShortcutBinding],
        handler: @escaping (ShortcutAction) -> Void
    ) {
        startCalls += 1
        lastBindings = bindings
        self.handler = handler
    }

    func stop() {
        stopCalls += 1
        handler = nil
    }

    func trigger(_ action: ShortcutAction) {
        handler?(action)
    }
}
