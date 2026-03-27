import Foundation

struct ShortcutPersistenceService {
    private struct StoredBinding: Codable {
        var actionRawValue: UInt32
        var keyCode: UInt32
        var carbonModifiers: UInt32
        var display: String
    }

    private let defaults: UserDefaults
    private let key: String

    init(
        defaults: UserDefaults = .standard,
        key: String = "mixo.shortcuts.bindings.v1"
    ) {
        self.defaults = defaults
        self.key = key
    }

    func load() -> [ShortcutAction: ShortcutBinding] {
        guard let data = defaults.data(forKey: key) else {
            return [:]
        }
        guard let storedBindings = try? JSONDecoder().decode([StoredBinding].self, from: data) else {
            defaults.removeObject(forKey: key)
            return [:]
        }

        var bindings: [ShortcutAction: ShortcutBinding] = [:]
        for storedBinding in storedBindings {
            guard let action = ShortcutAction(rawValue: storedBinding.actionRawValue) else {
                continue
            }
            bindings[action] = ShortcutBinding(
                keyCode: storedBinding.keyCode,
                carbonModifiers: storedBinding.carbonModifiers,
                display: storedBinding.display
            )
        }
        return bindings
    }

    func save(_ bindings: [ShortcutAction: ShortcutBinding]) {
        let storedBindings = bindings.map { action, binding in
            StoredBinding(
                actionRawValue: action.rawValue,
                keyCode: binding.keyCode,
                carbonModifiers: binding.carbonModifiers,
                display: binding.display
            )
        }
        guard let data = try? JSONEncoder().encode(storedBindings) else {
            return
        }
        defaults.set(data, forKey: key)
    }
}
