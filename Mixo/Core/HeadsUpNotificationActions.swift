import Foundation

enum HeadsUpNotificationConstants {
    static let categoryIdentifier = "mixo.breakHeadsUp.category"
    static let startNowActionIdentifier = "mixo.breakHeadsUp.action.startNow"
    static let delayActionIdentifier = "mixo.breakHeadsUp.action.delay"
    static let preBreakReminderIdentifier = "mixo.prebreak.headsup"
    static let defaultDelaySeconds = 300
    static let commandUserInfoKey = "command"
    static let delaySecondsUserInfoKey = "delaySeconds"
}

enum HeadsUpActionCommand: String {
    case startNow
    case delay
}

extension Notification.Name {
    static let mixoHeadsUpActionInvoked = Notification.Name("mixo.headsUpActionInvoked")
}
