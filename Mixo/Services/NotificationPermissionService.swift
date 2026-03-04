import Foundation
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

    func registerHeadsUpActions() {
        guard unsupportedContextReason == nil else {
            return
        }

        let startNowAction = UNNotificationAction(
            identifier: HeadsUpNotificationConstants.startNowActionIdentifier,
            title: "Start now",
            options: [.foreground]
        )
        let delayAction = UNNotificationAction(
            identifier: HeadsUpNotificationConstants.delayActionIdentifier,
            title: "Delay 5 min",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: HeadsUpNotificationConstants.categoryIdentifier,
            actions: [startNowAction, delayAction],
            intentIdentifiers: [],
            options: []
        )

        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
    }

    func schedulePreBreakReminder(
        in seconds: Int,
        leadTimeSeconds: Int,
        isLongBreak: Bool
    ) async throws {
        if let reason = unsupportedContextReason {
            throw ServiceError.unsupportedExecutionContext(reason: reason)
        }

        let boundedDelay = max(seconds, 1)
        let boundedLeadTime = max(leadTimeSeconds, 1)
        let title = isLongBreak ? "Long break starting soon" : "Break starting soon"
        let body = "Your break starts in \(boundedLeadTime) seconds."

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = HeadsUpNotificationConstants.categoryIdentifier
        content.userInfo = [
            HeadsUpNotificationConstants.delaySecondsUserInfoKey: HeadsUpNotificationConstants.defaultDelaySeconds
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(boundedDelay), repeats: false)
        let request = UNNotificationRequest(
            identifier: HeadsUpNotificationConstants.preBreakReminderIdentifier,
            content: content,
            trigger: trigger
        )
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [HeadsUpNotificationConstants.preBreakReminderIdentifier])

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: ())
            }
        }
    }

    func clearPreBreakReminder() {
        guard unsupportedContextReason == nil else {
            return
        }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [HeadsUpNotificationConstants.preBreakReminderIdentifier])
        center.removeDeliveredNotifications(withIdentifiers: [HeadsUpNotificationConstants.preBreakReminderIdentifier])
    }
}
