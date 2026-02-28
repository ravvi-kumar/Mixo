import Foundation
import OSLog

enum AppLogger {
    private static let fallbackSubsystem = "com.mixo.dev"

    static func make(_ category: String) -> Logger {
        Logger(
            subsystem: Bundle.main.bundleIdentifier ?? fallbackSubsystem,
            category: category
        )
    }
}
