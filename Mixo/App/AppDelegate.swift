import AppKit
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private let logger = AppLogger.make("lifecycle")
    private let notificationService = NotificationPermissionService()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        notificationService.registerHeadsUpActions()
        UNUserNotificationCenter.current().delegate = self
        logger.info("application_did_finish_launching")
    }

    func applicationWillTerminate(_ notification: Notification) {
        logger.info("application_will_terminate")
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer {
            completionHandler()
        }

        let command: HeadsUpActionCommand?
        switch response.actionIdentifier {
        case HeadsUpNotificationConstants.startNowActionIdentifier:
            command = .startNow
        case HeadsUpNotificationConstants.delayActionIdentifier:
            command = .delay
        default:
            command = nil
        }

        guard let command else {
            return
        }

        var userInfo: [String: Any] = [
            HeadsUpNotificationConstants.commandUserInfoKey: command.rawValue
        ]

        if command == .delay {
            let delaySeconds =
                (response.notification.request.content.userInfo[HeadsUpNotificationConstants.delaySecondsUserInfoKey] as? Int) ??
                (response.notification.request.content.userInfo[HeadsUpNotificationConstants.delaySecondsUserInfoKey] as? NSNumber)?.intValue ??
                HeadsUpNotificationConstants.defaultDelaySeconds
            userInfo[HeadsUpNotificationConstants.delaySecondsUserInfoKey] = delaySeconds
            logger.info("notification_action_received action=delay delay_seconds=\(delaySeconds, privacy: .public)")
        } else {
            logger.info("notification_action_received action=start_now")
        }

        NotificationCenter.default.post(
            name: .mixoHeadsUpActionInvoked,
            object: nil,
            userInfo: userInfo
        )
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
