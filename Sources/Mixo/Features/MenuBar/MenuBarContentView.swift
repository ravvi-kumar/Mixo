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
            LabeledContent("Timer", value: appState.timerModeDisplay)
            LabeledContent("Countdown", value: appState.timerRemainingDisplay)

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

            Divider()

            Button("Start Timer") {
                appState.startTimer()
            }
            .disabled(!appState.canStartTimer)

            Button("Pause Timer") {
                appState.pauseTimer()
            }
            .disabled(!appState.canPauseTimer)

            Button("Resume Timer") {
                appState.resumeTimer()
            }
            .disabled(!appState.canResumeTimer)

            Button("Take Break Now") {
                appState.takeBreakNow()
            }
            .disabled(!appState.canTakeBreakNow)

            Button("Reset Timer") {
                appState.resetTimer()
            }
            .disabled(!appState.canResetTimer)

            Divider()

            Button("Show Overlay Preview") {
                appState.showOverlayPreview()
            }

            Button("Hide Overlay") {
                appState.hideOverlay()
            }

            Button("Quit Mixo") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(12)
    }
}
