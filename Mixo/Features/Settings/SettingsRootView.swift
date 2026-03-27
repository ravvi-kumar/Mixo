import AppKit
import Carbon.HIToolbox
import Foundation
import SwiftUI

struct SettingsRootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedSection: SettingsSection = .breakSchedule

    @State private var recordingShortcutAction: ShortcutAction?
    @State private var shortcutRecorderMonitor: Any?
    @State private var shortcutRecorderMessage: String?

    var body: some View {
        HStack(spacing: 0) {
            sidebarPane
                .frame(width: 280, alignment: .leading)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1)

            detailPane
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.28), Color.black.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onDisappear {
            stopShortcutRecording(clearMessage: false)
        }
    }

    private var sidebarPane: some View {
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
                sectionHeader
                sectionDetail
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                keyValueRow("Idle Auto-Pause", value: appState.idlePauseThresholdDisplay)
                keyValueRow("Long Idle Reset", value: appState.longIdleResetThresholdDisplay)
                keyValueRow("Fullscreen Deferral", value: appState.timerSmartPauseFullscreenEnabled ? "Enabled" : "Disabled")
                keyValueRow("Media Deferral", value: appState.timerSmartPauseMediaEnabled ? "Enabled" : "Disabled")
                keyValueRow("Work Hours", value: appState.workHoursDisplay)
                keyValueRow("Smart Pause Reason", value: appState.smartPauseReasonDisplay)
                keyValueRow("Global Shortcuts", value: appState.globalShortcutsStatusDisplay)
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
                title: "Work Hours Window",
                subtitle: "Optionally restrict timer activity to a daily time window."
            ) {
                Toggle("Restrict Timer to Work Hours", isOn: $appState.timerWorkHoursEnabled)

                HStack(spacing: 12) {
                    Stepper(
                        "Start Hour: \(appState.timerWorkdayStartHour)",
                        value: $appState.timerWorkdayStartHour,
                        in: 0 ... 23
                    )

                    Stepper(
                        "Start Min: \(appState.timerWorkdayStartMinute)",
                        value: $appState.timerWorkdayStartMinute,
                        in: 0 ... 59,
                        step: 5
                    )
                }
                .disabled(!appState.timerWorkHoursEnabled)

                HStack(spacing: 12) {
                    Stepper(
                        "End Hour: \(appState.timerWorkdayEndHour)",
                        value: $appState.timerWorkdayEndHour,
                        in: 0 ... 23
                    )

                    Stepper(
                        "End Min: \(appState.timerWorkdayEndMinute)",
                        value: $appState.timerWorkdayEndMinute,
                        in: 0 ... 59,
                        step: 5
                    )
                }
                .disabled(!appState.timerWorkHoursEnabled)

                if appState.timerWorkHoursEnabled {
                    Text(
                        "Active window: \(clockLabel(hour: appState.timerWorkdayStartHour, minute: appState.timerWorkdayStartMinute)) - \(clockLabel(hour: appState.timerWorkdayEndHour, minute: appState.timerWorkdayEndMinute))"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    Text("Work hours are off. Timer can run at any time.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
                title: "Detector Toggles",
                subtitle: "Enable or disable each smart-pause detector."
            ) {
                Toggle("Idle Activity", isOn: $appState.timerSmartPauseIdleEnabled)
                Toggle("Fullscreen App", isOn: $appState.timerSmartPauseFullscreenEnabled)
                Toggle("Media Playback", isOn: $appState.timerSmartPauseMediaEnabled)

                Text("Apply timer settings while timer is idle to persist detector changes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            SettingsCard(
                title: "Idle Auto-Pause Thresholds",
                subtitle: "Idle thresholds apply only when Idle Activity detector is enabled."
            ) {
                Stepper(
                    "Pause Timer After Idle: \(appState.timerIdlePauseThresholdSeconds) sec",
                    value: $appState.timerIdlePauseThresholdSeconds,
                    in: 0 ... 1800,
                    step: 5
                )
                .disabled(!appState.timerSmartPauseIdleEnabled)

                Stepper(
                    "Reset Timer After Long Idle: \(appState.timerLongIdleResetThresholdSeconds) sec",
                    value: $appState.timerLongIdleResetThresholdSeconds,
                    in: 0 ... 7200,
                    step: 10
                )
                .disabled(!appState.timerSmartPauseIdleEnabled)

                if !appState.timerSmartPauseIdleEnabled {
                    Text("Idle detector is disabled. Thresholds are ignored.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if appState.timerIdlePauseThresholdSeconds == 0 {
                    Text("Idle auto-pause is disabled when threshold is 0 seconds.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Apply timer settings while timer is idle to save this threshold.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if appState.timerLongIdleResetThresholdSeconds == 0 {
                    Text("Long-idle reset is disabled when threshold is 0 seconds.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            SettingsCard(
                title: "Runtime Status",
                subtitle: "Current smart-pause state as seen by the timer engine."
            ) {
                keyValueRow("Active Reason", value: appState.smartPauseReasonDisplay)
                keyValueRow("Idle Detector", value: appState.timerSmartPauseIdleEnabled ? "Enabled" : "Disabled")
                keyValueRow("Fullscreen Detector", value: appState.timerSmartPauseFullscreenEnabled ? "Enabled" : "Disabled")
                keyValueRow("Media Detector", value: appState.timerSmartPauseMediaEnabled ? "Enabled" : "Disabled")
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
            subtitle: "Record custom global shortcuts for core timer controls."
        ) {
            keyValueRow("Status", value: appState.globalShortcutsStatusDisplay)

            if let shortcutRecorderMessage {
                Text(shortcutRecorderMessage)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Divider()

            ForEach(ShortcutAction.allCases, id: \.self) { action in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(action.title)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(shortcutDisplay(for: action))
                        .fontWeight(.semibold)
                        .foregroundStyle(recordingShortcutAction == action ? .orange : .secondary)

                    Button(recordingShortcutAction == action ? "Cancel" : "Record") {
                        toggleShortcutRecording(for: action)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Button("Default") {
                        stopShortcutRecording(clearMessage: true)
                        appState.resetShortcutBinding(for: action)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(appState.shortcutBindingDisplay(for: action) == action.defaultBinding.display)
                }
                .font(.system(size: 13))
            }

            Divider()

            HStack {
                Spacer()

                Button("Reset All to Defaults") {
                    stopShortcutRecording(clearMessage: true)
                    appState.resetAllShortcutBindings()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            Text("Record captures the next key combination with Command, Control, Option, or Shift.")
                .font(.caption)
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

    private func clockLabel(hour: Int, minute: Int) -> String {
        String(format: "%02d:%02d", max(0, min(hour, 23)), max(0, min(minute, 59)))
    }

    private func shortcutDisplay(for action: ShortcutAction) -> String {
        if recordingShortcutAction == action {
            return "Press shortcut..."
        }
        return appState.shortcutBindingDisplay(for: action)
    }

    private func toggleShortcutRecording(for action: ShortcutAction) {
        if recordingShortcutAction == action {
            stopShortcutRecording(clearMessage: true)
            return
        }

        stopShortcutRecording(clearMessage: false)
        recordingShortcutAction = action
        shortcutRecorderMessage = "Press new shortcut for \(action.title)."
        shortcutRecorderMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handleShortcutCaptureEvent(event, for: action)
        }
    }

    private func stopShortcutRecording(clearMessage: Bool) {
        if let shortcutRecorderMonitor {
            NSEvent.removeMonitor(shortcutRecorderMonitor)
            self.shortcutRecorderMonitor = nil
        }
        recordingShortcutAction = nil
        if clearMessage {
            shortcutRecorderMessage = nil
        }
    }

    private func handleShortcutCaptureEvent(_ event: NSEvent, for action: ShortcutAction) -> NSEvent? {
        guard recordingShortcutAction == action else {
            return event
        }

        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if event.keyCode == UInt16(kVK_Escape), modifiers.isDisjoint(with: [.command, .control, .option, .shift]) {
            stopShortcutRecording(clearMessage: true)
            return nil
        }

        guard let binding = makeShortcutBinding(from: event) else {
            shortcutRecorderMessage = "Use a non-modifier key with Command, Control, or Option."
            return nil
        }

        let updateResult = appState.updateShortcutBinding(binding, for: action)
        switch updateResult {
        case .updated:
            stopShortcutRecording(clearMessage: true)
        case let .conflict(existingAction):
            shortcutRecorderMessage = "Conflict: already used by \(existingAction.title)."
        }
        return nil
    }

    private func makeShortcutBinding(from event: NSEvent) -> ShortcutBinding? {
        guard !Self.modifierOnlyKeyCodes.contains(event.keyCode) else {
            return nil
        }

        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        var carbonModifiers: UInt32 = 0
        var components: [String] = []

        if flags.contains(.control) {
            carbonModifiers |= UInt32(controlKey)
            components.append("Control")
        }
        if flags.contains(.option) {
            carbonModifiers |= UInt32(optionKey)
            components.append("Option")
        }
        if flags.contains(.shift) {
            carbonModifiers |= UInt32(shiftKey)
            components.append("Shift")
        }
        if flags.contains(.command) {
            carbonModifiers |= UInt32(cmdKey)
            components.append("Command")
        }

        guard carbonModifiers != 0 else {
            return nil
        }

        let keyTitle = keyTitle(for: event)
        guard !keyTitle.isEmpty else {
            return nil
        }

        return ShortcutBinding(
            keyCode: UInt32(event.keyCode),
            carbonModifiers: carbonModifiers,
            display: (components + [keyTitle]).joined(separator: "+")
        )
    }

    private func keyTitle(for event: NSEvent) -> String {
        switch event.keyCode {
        case UInt16(kVK_Return):
            return "Return"
        case UInt16(kVK_Tab):
            return "Tab"
        case UInt16(kVK_Space):
            return "Space"
        case UInt16(kVK_Delete):
            return "Delete"
        case UInt16(kVK_ForwardDelete):
            return "ForwardDelete"
        case UInt16(kVK_Escape):
            return "Escape"
        case UInt16(kVK_Home):
            return "Home"
        case UInt16(kVK_End):
            return "End"
        case UInt16(kVK_PageUp):
            return "PageUp"
        case UInt16(kVK_PageDown):
            return "PageDown"
        case UInt16(kVK_LeftArrow):
            return "LeftArrow"
        case UInt16(kVK_RightArrow):
            return "RightArrow"
        case UInt16(kVK_DownArrow):
            return "DownArrow"
        case UInt16(kVK_UpArrow):
            return "UpArrow"
        default:
            guard
                let characters = event.charactersIgnoringModifiers?.trimmingCharacters(in: .whitespacesAndNewlines),
                !characters.isEmpty
            else {
                return "Key\(event.keyCode)"
            }
            return characters.uppercased()
        }
    }

    private static let modifierOnlyKeyCodes: Set<UInt16> = [
        UInt16(kVK_Command),
        UInt16(kVK_RightCommand),
        UInt16(kVK_Shift),
        UInt16(kVK_RightShift),
        UInt16(kVK_Option),
        UInt16(kVK_RightOption),
        UInt16(kVK_Control),
        UInt16(kVK_RightControl),
        UInt16(kVK_CapsLock),
        UInt16(kVK_Function)
    ]
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
