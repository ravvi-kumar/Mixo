import SwiftUI

struct SettingsRootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedSection: SettingsSection = .breakSchedule
    @State private var isSidebarVisible = true

    // Sprint 06 preview controls (UI-only for now).
    @State private var pauseOnMeetings = true
    @State private var pauseOnVideoPlayback = true
    @State private var pauseOnCalendarEvents = true
    @State private var pauseOnDeepFocusApps = true
    @State private var pauseOnGaming = false
    @State private var pauseOnScreenSharing = false
    @State private var smartPauseCooldownMinutes = 2
    @State private var smartPauseAwayMode: SmartPauseAwayMode = .automatic

    var body: some View {
        HStack(spacing: 0) {
            sidebarPane
                .frame(width: isSidebarVisible ? 280 : 0, alignment: .leading)
                .opacity(isSidebarVisible ? 1 : 0)
                .clipped()
                .allowsHitTesting(isSidebarVisible)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: isSidebarVisible ? 1 : 0)

            detailPane
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.28), Color.black.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .animation(.easeInOut(duration: 0.2), value: isSidebarVisible)
        .toolbar(.hidden, for: .windowToolbar)
    }

    private var sidebarPane: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.leading")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
                .help("Hide Sidebar")

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            List(selection: $selectedSection) {
                Section {
                    sidebarRow(for: .general)
                }

                Section("Focus & Wellbeing") {
                    sidebarRow(for: .breakSchedule)
                    sidebarRow(for: .smartPause)
                }

                Section("Personalize") {
                    sidebarRow(for: .soundEffects)
                    sidebarRow(for: .keyboardShortcuts)
                }

                Section("Mixo") {
                    sidebarRow(for: .about)
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.2), Color.black.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var detailPane: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if !isSidebarVisible {
                    HStack {
                        Button(action: toggleSidebar) {
                            Image(systemName: "sidebar.leading")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 28, height: 28)
                                .background(
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .fill(Color.white.opacity(0.06))
                                )
                        }
                        .buttonStyle(.plain)
                        .help("Show Sidebar")

                        Spacer()
                    }
                }

                sectionHeader
                sectionDetail
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func toggleSidebar() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isSidebarVisible.toggle()
        }
    }

    private func sidebarRow(for section: SettingsSection) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(section.tint.gradient)
                .frame(width: 22, height: 22)
                .overlay {
                    Image(systemName: section.iconName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                }

            Text(section.title)
                .font(.system(size: 15, weight: .semibold))
        }
        .padding(.vertical, 4)
        .tag(section)
    }

    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(selectedSection.title)
                .font(.system(size: 34, weight: .bold))

            Text(selectedSection.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var sectionDetail: some View {
        switch selectedSection {
        case .general:
            generalPanel
        case .breakSchedule:
            breaksPanel
        case .smartPause:
            smartPausePanel
        case .soundEffects:
            soundEffectsPanel
        case .keyboardShortcuts:
            keyboardShortcutsPanel
        case .about:
            aboutPanel
        }
    }

    private var generalPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsCard(
                title: "Notification Access",
                subtitle: "Allow Mixo to send break reminders and heads-up actions."
            ) {
                keyValueRow("Permission", value: appState.notificationStatusDisplay)
                keyValueRow(
                    "Fallback",
                    value: appState.notificationFallbackStatusDisplay,
                    valueColor: appState.notificationFallbackStatus == nil ? .secondary : .orange
                )

                if let fallbackStatus = appState.notificationFallbackStatus {
                    Text(fallbackStatus)
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.top, 2)
                }

                Divider()

                Button("Request Notification Permission") {
                    appState.requestNotificationPermission()
                }
                .buttonStyle(.borderedProminent)
            }

            SettingsCard(
                title: "Runtime Status",
                subtitle: "Quick glance at the active timer state."
            ) {
                keyValueRow("Timer State", value: appState.timerModeDisplay)
                keyValueRow("Countdown", value: appState.timerRemainingDisplay)
                keyValueRow("Break Policy", value: appState.breakPolicyModeDisplay)
                keyValueRow("Heads-up Lead", value: appState.preBreakNotificationLeadTimeDisplay)
            }
        }
    }

    private var breaksPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsCard(
                title: "Current Session",
                subtitle: "Live timer runtime values."
            ) {
                keyValueRow("Timer State", value: appState.timerModeDisplay)
                keyValueRow("Current Countdown", value: appState.timerRemainingDisplay)
                keyValueRow("Until Long Break", value: appState.shortBreaksUntilLongBreakDisplay)
                keyValueRow("Active Policy", value: appState.breakPolicyModeDisplay)
            }

            SettingsCard(
                title: "Schedule Defaults",
                subtitle: "These values are applied when starting a fresh cycle."
            ) {
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
            }

            SettingsCard(
                title: "Break Policy",
                subtitle: "Control skip behavior while a break is active."
            ) {
                Picker("Policy", selection: $appState.timerBreakPolicyMode) {
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
                    Text("Skip delay is only used in Skip After Delay mode.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            SettingsCard(
                title: "Heads-up Reminder",
                subtitle: "How early to show warning notification before the next break."
            ) {
                Stepper(
                    "Heads-up Lead Time: \(appState.timerPreBreakNotificationLeadTimeSeconds) sec",
                    value: $appState.timerPreBreakNotificationLeadTimeSeconds,
                    in: 0 ... 300,
                    step: 5
                )

                if appState.timerPreBreakNotificationLeadTimeSeconds == 0 {
                    Text("Heads-up is disabled when lead time is 0 seconds.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Button("Apply Timer Settings") {
                    appState.applyTimerSettings()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!appState.canApplyTimerSettings)

                if !appState.canApplyTimerSettings {
                    Text("Reset or finish the current timer cycle before applying settings.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var smartPausePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsCard(
                title: "Automatically Pause During",
                subtitle: "These controls are the visual foundation for Sprint 06 smart pause behavior."
            ) {
                smartPauseRuleRow(
                    iconName: "headphones",
                    title: "Meetings or Calls",
                    subtitle: "Pause breaks while calls or meetings are active.",
                    isOn: $pauseOnMeetings
                )

                smartPauseRuleRow(
                    iconName: "play.rectangle.fill",
                    title: "Video Playback",
                    subtitle: "Pause breaks while video playback is detected.",
                    isOn: $pauseOnVideoPlayback
                )

                smartPauseRuleRow(
                    iconName: "calendar",
                    title: "Calendar Events",
                    subtitle: "Pause breaks when a calendar event is active.",
                    isOn: $pauseOnCalendarEvents
                )

                smartPauseRuleRow(
                    iconName: "moon.zzz.fill",
                    title: "Deep Focus Apps",
                    subtitle: "Pause breaks when selected focus apps are frontmost.",
                    isOn: $pauseOnDeepFocusApps
                )

                smartPauseRuleRow(
                    iconName: "gamecontroller.fill",
                    title: "Gaming",
                    subtitle: "Pause breaks while full-screen games are running.",
                    isOn: $pauseOnGaming
                )

                smartPauseRuleRow(
                    iconName: "rectangle.on.rectangle",
                    title: "Screen Recording or Sharing",
                    subtitle: "Pause breaks while recording or sharing your screen.",
                    isOn: $pauseOnScreenSharing
                )
            }

            SettingsCard(title: "Cooldown", subtitle: "Delay before smart pause re-triggers after it ends.") {
                HStack {
                    Text("Cooldown after Smart Pause ends")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Stepper(
                        "\(smartPauseCooldownMinutes) min",
                        value: $smartPauseCooldownMinutes,
                        in: 0 ... 15
                    )
                    .frame(width: 170)
                }
            }

            SettingsCard(title: "When You Are Away", subtitle: "How Mixo should behave when you're away from keyboard.") {
                Picker("Pause or Resume", selection: $smartPauseAwayMode) {
                    ForEach(SmartPauseAwayMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 240, alignment: .leading)

                Text("Automatic mode will pause or resume based on idle and active-context signals once Sprint 06 behavior is wired.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var soundEffectsPanel: some View {
        SettingsCard(
            title: "Sound Effects",
            subtitle: "Audio customization surface for break start/end cues."
        ) {
            Text("Current behavior: break start and break end chimes play automatically.")
                .foregroundStyle(.secondary)

            Text("Next: expose mute/volume/device preferences in this panel.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var keyboardShortcutsPanel: some View {
        SettingsCard(
            title: "Keyboard Shortcuts",
            subtitle: "Global controls will be managed in Sprint 07."
        ) {
            Text("Planned actions: Start, Pause/Resume, Take Break Now, Skip Break, Reset.")
                .foregroundStyle(.secondary)
        }
    }

    private var aboutPanel: some View {
        SettingsCard(
            title: "About Mixo",
            subtitle: "Menu bar break coach for healthy focus sessions."
        ) {
            keyValueRow("App Name", value: "Mixo")
            keyValueRow("Bundle ID", value: Bundle.main.bundleIdentifier ?? "Unavailable")
            keyValueRow("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Dev")
            keyValueRow("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Dev")
        }
    }

    private func keyValueRow(_ title: String, value: String, valueColor: Color = .secondary) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .font(.system(size: 13))
    }

    private func smartPauseRuleRow(
        iconName: String,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 34, height: 34)
                .overlay {
                    Image(systemName: iconName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Options...") {}
                .buttonStyle(.bordered)
                .controlSize(.small)

            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.vertical, 2)
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

private struct SettingsCard<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder var content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 22, weight: .bold))

            if let subtitle {
                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                content
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.035))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private enum SettingsSection: String, Hashable, CaseIterable, Identifiable {
    case general
    case breakSchedule
    case smartPause
    case soundEffects
    case keyboardShortcuts
    case about

    var id: Self { self }

    var title: String {
        switch self {
        case .general:
            return "General"
        case .breakSchedule:
            return "Break Schedule"
        case .smartPause:
            return "Smart Pause"
        case .soundEffects:
            return "Sound Effects"
        case .keyboardShortcuts:
            return "Keyboard Shortcuts"
        case .about:
            return "About"
        }
    }

    var subtitle: String {
        switch self {
        case .general:
            return "Permissions, health, and runtime status."
        case .breakSchedule:
            return "Timer defaults, policy behavior, and heads-up lead time."
        case .smartPause:
            return "Pause automation controls for focus-safe break timing."
        case .soundEffects:
            return "Audio behavior for break transitions."
        case .keyboardShortcuts:
            return "Global action bindings and quick controls."
        case .about:
            return "Application metadata and release information."
        }
    }

    var iconName: String {
        switch self {
        case .general:
            return "gearshape.fill"
        case .breakSchedule:
            return "timer"
        case .smartPause:
            return "pause.fill"
        case .soundEffects:
            return "speaker.wave.2.fill"
        case .keyboardShortcuts:
            return "command"
        case .about:
            return "info.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .general:
            return .purple
        case .breakSchedule:
            return .pink
        case .smartPause:
            return .indigo
        case .soundEffects:
            return .red
        case .keyboardShortcuts:
            return .orange
        case .about:
            return .yellow
        }
    }
}

private enum SmartPauseAwayMode: String, CaseIterable {
    case automatic
    case pauseOnly
    case resumeOnly

    var title: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .pauseOnly:
            return "Pause Only"
        case .resumeOnly:
            return "Resume Only"
        }
    }
}
