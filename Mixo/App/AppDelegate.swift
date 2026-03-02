import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let logger = AppLogger.make("lifecycle")

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        logger.info("application_did_finish_launching")
    }

    func applicationWillTerminate(_ notification: Notification) {
        logger.info("application_will_terminate")
    }
}
