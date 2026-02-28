import AppKit
import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mixo")
                .font(.headline)

            Text("Foundation shell running")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            LabeledContent("Notifications", value: appState.notificationStatusDisplay)

            Text(appState.lastActionMessage)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Divider()

            if #available(macOS 14.0, *) {
                SettingsLink {
                    Text("Open Settings")
                }
            } else {
                Button("Open Settings") {
                    appState.openSettingsLegacy()
                }
            }

            Button("Request Notification Permission") {
                appState.requestNotificationPermission()
            }

            Button("Quit Mixo") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(12)
    }
}
