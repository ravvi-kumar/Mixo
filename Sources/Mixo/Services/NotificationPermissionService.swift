import UserNotifications

@MainActor
struct NotificationPermissionService {
    enum ServiceError: Error {
        case unsupportedExecutionContext
    }

    private var canUseNotificationCenter: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    func requestAuthorization() async throws -> Bool {
        guard canUseNotificationCenter else {
            throw ServiceError.unsupportedExecutionContext
        }

        let center = UNUserNotificationCenter.current()
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: granted)
            }
        }
    }

    func currentStatus() async -> UNAuthorizationStatus {
        guard canUseNotificationCenter else {
            return .notDetermined
        }

        let center = UNUserNotificationCenter.current()
        return await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }
}
