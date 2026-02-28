import AppKit
import Foundation
import UserNotifications

@MainActor
final class AppState: ObservableObject {
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    @Published var lastActionMessage = "App started"

    var menuBarLabel: String {
        "Mixo"
    }

    var notificationStatusDisplay: String {
        switch notificationStatus {
        case .notDetermined:
            return "Not requested"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }

    private let notificationService: NotificationPermissionService
    private let logger = AppLogger.make("state")

    init(notificationService: NotificationPermissionService = .init()) {
        self.notificationService = notificationService
        Task { [weak self] in
            await self?.refreshNotificationStatus()
        }
    }

    func openSettingsLegacy() {
        logger.info("action_open_settings_legacy")
        lastActionMessage = "Opened settings"
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    func requestNotificationPermission() {
        logger.info("action_request_notification_permission")
        Task {
            do {
                _ = try await notificationService.requestAuthorization()
                await refreshNotificationStatus()
                lastActionMessage = "Notification permission updated"
            } catch NotificationPermissionService.ServiceError.unsupportedExecutionContext {
                logger.error("notification_permission_unsupported_context")
                lastActionMessage = "Notifications require running from a bundled .app (not bare Xcode product)."
            } catch {
                logger.error("notification_permission_error: \(String(describing: error), privacy: .public)")
                lastActionMessage = "Notification permission request failed"
            }
        }
    }

    func refreshNotificationStatus() async {
        let status = await notificationService.currentStatus()
        notificationStatus = status
        logger.info("notification_status=\(status.rawValue)")
    }
}
