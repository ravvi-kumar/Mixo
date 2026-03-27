import AppKit
import Carbon.HIToolbox
import Foundation

struct ShortcutBinding: Codable, Equatable {
    let keyCode: UInt32
    let carbonModifiers: UInt32
    let display: String
}

enum ShortcutAction: UInt32, CaseIterable {
    case start = 1
    case pauseResume = 2
    case skipBreak = 3

    var title: String {
        switch self {
        case .start:
            return "Start Timer"
        case .pauseResume:
            return "Pause/Resume Timer"
        case .skipBreak:
            return "Skip Break"
        }
    }

    var defaultBinding: ShortcutBinding {
        switch self {
        case .start:
            return ShortcutBinding(
                keyCode: UInt32(kVK_ANSI_S),
                carbonModifiers: UInt32(cmdKey | controlKey),
                display: "Control+Command+S"
            )
        case .pauseResume:
            return ShortcutBinding(
                keyCode: UInt32(kVK_ANSI_P),
                carbonModifiers: UInt32(cmdKey | controlKey),
                display: "Control+Command+P"
            )
        case .skipBreak:
            return ShortcutBinding(
                keyCode: UInt32(kVK_ANSI_K),
                carbonModifiers: UInt32(cmdKey | controlKey),
                display: "Control+Command+K"
            )
        }
    }
}

protocol ShortcutManaging: AnyObject {
    func start(
        bindings: [ShortcutAction: ShortcutBinding],
        handler: @escaping (ShortcutAction) -> Void
    )
    func stop()
}

final class GlobalShortcutManager: ShortcutManaging {
    private let logger = AppLogger.make("shortcuts")
    private var onShortcut: ((ShortcutAction) -> Void)?
    private var eventHandlerRef: EventHandlerRef?
    private var registeredHotKeyRefs: [EventHotKeyRef] = []

    private static let signature: OSType = GlobalShortcutManager.fourCharCode("MIXO")

    func start(
        bindings: [ShortcutAction: ShortcutBinding],
        handler: @escaping (ShortcutAction) -> Void
    ) {
        stop()
        onShortcut = handler

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let handlerStatus = InstallEventHandler(
            GetEventDispatcherTarget(),
            Self.hotKeyEventHandler,
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandlerRef
        )

        guard handlerStatus == noErr else {
            logger.error("shortcut_event_handler_install_failed status=\(handlerStatus, privacy: .public)")
            onShortcut = nil
            return
        }

        registerAllHotKeys(bindings: bindings)
        logger.info("shortcut_manager_started")
    }

    func stop() {
        for hotKeyRef in registeredHotKeyRefs {
            UnregisterEventHotKey(hotKeyRef)
        }
        registeredHotKeyRefs.removeAll()

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
        onShortcut = nil
    }

    deinit {
        stop()
    }

    private func registerAllHotKeys(bindings: [ShortcutAction: ShortcutBinding]) {
        for action in ShortcutAction.allCases {
            let binding = bindings[action] ?? action.defaultBinding
            var hotKeyRef: EventHotKeyRef?
            var hotKeyID = EventHotKeyID(
                signature: Self.signature,
                id: action.rawValue
            )
            let status = RegisterEventHotKey(
                binding.keyCode,
                binding.carbonModifiers,
                hotKeyID,
                GetEventDispatcherTarget(),
                0,
                &hotKeyRef
            )

            guard status == noErr, let hotKeyRef else {
                logger.error(
                    "shortcut_register_failed action=\(action.rawValue, privacy: .public) status=\(status, privacy: .public)"
                )
                continue
            }
            registeredHotKeyRefs.append(hotKeyRef)
            logger.info("shortcut_registered action=\(action.rawValue, privacy: .public)")
        }
    }

    private func handleHotKeyEvent(_ event: EventRef) -> OSStatus {
        var hotKeyID = EventHotKeyID()
        var size = MemoryLayout<EventHotKeyID>.size
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            &size,
            &hotKeyID
        )
        guard status == noErr, hotKeyID.signature == Self.signature else {
            return noErr
        }

        guard let action = ShortcutAction(rawValue: hotKeyID.id) else {
            return noErr
        }
        onShortcut?(action)
        return noErr
    }

    private static let hotKeyEventHandler: EventHandlerUPP = { _, event, userData in
        guard let event, let userData else {
            return noErr
        }
        let manager = Unmanaged<GlobalShortcutManager>.fromOpaque(userData).takeUnretainedValue()
        return manager.handleHotKeyEvent(event)
    }

    private static func fourCharCode(_ value: String) -> OSType {
        value.unicodeScalars.reduce(0) { accumulator, scalar in
            (accumulator << 8) + OSType(scalar.value)
        }
    }
}
