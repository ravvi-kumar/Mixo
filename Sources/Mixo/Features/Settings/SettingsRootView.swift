import SwiftUI

struct SettingsRootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            placeholderPanel(
                title: "General",
                subtitle: "App startup, notifications, and basic behavior settings."
            )
            .tabItem {
                Label("General", systemImage: "gearshape")
            }

            placeholderPanel(
                title: "Breaks",
                subtitle: "Short and long break controls will be wired in Phase 2 and Phase 4."
            )
            .tabItem {
                Label("Breaks", systemImage: "timer")
            }

            placeholderPanel(
                title: "Advanced",
                subtitle: "Smart pause, shortcuts, and integrations will be added later."
            )
            .tabItem {
                Label("Advanced", systemImage: "slider.horizontal.3")
            }
        }
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
