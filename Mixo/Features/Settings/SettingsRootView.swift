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
            LabeledContent("Short Breaks Until Long Break", value: appState.shortBreaksUntilLongBreakDisplay)
            LabeledContent("Active Break Policy", value: appState.breakPolicyModeDisplay)

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

            Stepper(
                "Long Break Duration: \(appState.timerLongBreakDurationMinutes) min",
                value: $appState.timerLongBreakDurationMinutes,
                in: 1 ... 60
            )

            Stepper(
                "Long Break Every: \(appState.timerLongBreakEveryShortBreaks) short breaks",
                value: $appState.timerLongBreakEveryShortBreaks,
                in: 1 ... 12
            )

            Picker("Break Policy", selection: $appState.timerBreakPolicyMode) {
                ForEach(BreakPolicyMode.allCases, id: \.self) { mode in
                    Text(policyLabel(for: mode)).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Stepper(
                "Skip Delay: \(appState.timerSkipDelaySeconds) sec",
                value: $appState.timerSkipDelaySeconds,
                in: 0 ... 300,
                step: 5
            )
            .disabled(appState.timerBreakPolicyMode != .skipAfterDelay)

            if appState.timerBreakPolicyMode != .skipAfterDelay {
                Text("Skip delay is used only in Skip After Delay mode.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Stepper(
                "Heads-up Notification Lead Time: \(appState.timerPreBreakNotificationLeadTimeSeconds) sec",
                value: $appState.timerPreBreakNotificationLeadTimeSeconds,
                in: 0 ... 300,
                step: 5
            )

            if appState.timerPreBreakNotificationLeadTimeSeconds == 0 {
                Text("Heads-up notification is disabled when lead time is 0 seconds.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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
            LabeledContent("Heads-up Fallback", value: appState.notificationFallbackStatusDisplay)

            if let fallbackStatus = appState.notificationFallbackStatus {
                Text(fallbackStatus)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Button("Request Notification Permission") {
                appState.requestNotificationPermission()
            }

            Spacer()
        }
        .padding(24)
    }

    private func policyLabel(for mode: BreakPolicyMode) -> String {
        switch mode {
        case .skipAnytime:
            return "Skip Anytime"
        case .skipAfterDelay:
            return "Skip After Delay"
        case .lock:
            return "Lock"
        }
    }
}
