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
            LabeledContent("Break Policy", value: appState.breakPolicyModeDisplay)
            LabeledContent("Heads-up Lead", value: appState.preBreakNotificationLeadTimeDisplay)
            LabeledContent("Idle Auto-Pause", value: appState.idlePauseThresholdDisplay)
            LabeledContent("Long Idle Reset", value: appState.longIdleResetThresholdDisplay)
            LabeledContent("Fullscreen Deferral", value: appState.timerSmartPauseFullscreenEnabled ? "Enabled" : "Disabled")
            LabeledContent("Media Deferral", value: appState.timerSmartPauseMediaEnabled ? "Enabled" : "Disabled")
            LabeledContent("Work Hours", value: appState.workHoursDisplay)
            LabeledContent("Smart Pause", value: appState.smartPauseReasonDisplay)
            LabeledContent("Global Shortcuts", value: appState.globalShortcutsStatusDisplay)
            LabeledContent("Heads-up Fallback", value: appState.notificationFallbackStatusDisplay)

            if let fallbackStatus = appState.notificationFallbackStatus {
                Text(fallbackStatus)
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }

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

            Button("Start Timer \(shortcutSuffix(for: .start))") {
                appState.startTimer()
            }
            .disabled(!appState.canStartTimer)

            Button("Pause Timer \(shortcutSuffix(for: .pauseResume))") {
                appState.pauseTimer()
            }
            .disabled(!appState.canPauseTimer)

            Button("Resume Timer \(shortcutSuffix(for: .pauseResume))") {
                appState.resumeTimer()
            }
            .disabled(!appState.canResumeTimer)

            Button("Take Break Now") {
                appState.takeBreakNow()
            }
            .disabled(!appState.canTakeBreakNow)

            if appState.shouldShowSkipBreakAction {
                Button("Skip Break \(shortcutSuffix(for: .skipBreak))") {
                    appState.skipBreak()
                }
                .disabled(!appState.canSkipBreak)
            }

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

            Button("Overlay Diagnostics") {
                appState.logOverlayDiagnostics()
            }

            Button("Quit Mixo") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(12)
    }

    private func shortcutSuffix(for action: ShortcutAction) -> String {
        "(\(appState.shortcutBindingDisplay(for: action)))"
    }
}
