import UserNotifications

struct NotificationPermissionService {
    enum ServiceError: Error {
        case unsupportedExecutionContext(reason: String)
    }

    private var unsupportedContextReason: String? {
        let mainBundle = Bundle.main

        guard mainBundle.bundleURL.pathExtension == "app" else {
            return "Notifications require launching Mixo from a bundled .app target."
        }

        guard mainBundle.bundleIdentifier?.isEmpty == false else {
            return "Notifications require CFBundleIdentifier in the app bundle."
        }

        guard mainBundle.object(forInfoDictionaryKey: "CFBundleExecutable") != nil else {
            return "Notifications require a valid app bundle Info.plist."
        }

        return nil
    }

    func requestAuthorization() async throws -> Bool {
        if let reason = unsupportedContextReason {
            throw ServiceError.unsupportedExecutionContext(reason: reason)
        }

        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func currentStatus() async -> UNAuthorizationStatus {
        guard unsupportedContextReason == nil else {
            return .notDetermined
        }

        let center = UNUserNotificationCenter.current()
        return await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                let status = settings.authorizationStatus
                DispatchQueue.main.async {
                    continuation.resume(returning: status)
                }
            }
        }
    }
}
