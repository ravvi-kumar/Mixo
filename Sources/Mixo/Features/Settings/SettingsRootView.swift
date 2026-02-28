import SwiftUI

struct SettingsRootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            generalPanel
            .tabItem {
                Label("General", systemImage: "gearshape")
            }

            breaksPanel
            .tabItem {
                Label("Breaks", systemImage: "timer")
            }

            advancedPanel
            .tabItem {
                Label("Advanced", systemImage: "slider.horizontal.3")
            }
        }
    }

    private var generalPanel: some View {
        placeholderPanel(
            title: "General",
            subtitle: "App startup, notifications, and basic behavior settings."
        )
    }

    private var advancedPanel: some View {
        placeholderPanel(
            title: "Advanced",
            subtitle: "Smart pause, shortcuts, and integrations will be added later."
        )
    }

    private var breaksPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Breaks")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tune the short-break timer defaults used by the running timer engine.")
                .foregroundStyle(.secondary)

            Divider()

            LabeledContent("Timer State", value: appState.timerModeDisplay)
            LabeledContent("Current Countdown", value: appState.timerRemainingDisplay)

            Stepper(
                "Work Duration: \(appState.timerWorkDurationMinutes) min",
                value: $appState.timerWorkDurationMinutes,
                in: 1 ... 120
            )

            Stepper(
                "Break Duration: \(appState.timerBreakDurationSeconds) sec",
                value: $appState.timerBreakDurationSeconds,
                in: 5 ... 600,
                step: 5
            )

            Button("Apply Timer Settings") {
                appState.applyTimerSettings()
            }
            .disabled(!appState.canApplyTimerSettings)

            if !appState.canApplyTimerSettings {
                Text("Reset or finish the current timer cycle before applying settings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(24)
    }

    private func placeholderPanel(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(subtitle)
                .foregroundStyle(.secondary)

            Divider()

            LabeledContent("Notification Permission", value: appState.notificationStatusDisplay)

            Button("Request Notification Permission") {
                appState.requestNotificationPermission()
            }

            Spacer()
        }
        .padding(24)
    }
}
