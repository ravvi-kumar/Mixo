import SwiftUI

@main
struct MixoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()
    private let logger = AppLogger.make("app")

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(appState)
                .frame(width: 260)
                .onAppear {
                    logger.info("menu_bar_rendered")
                }
        } label: {
            Label(appState.menuBarLabel, systemImage: "moon.zzz")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsRootView()
                .environmentObject(appState)
                .frame(minWidth: 980, minHeight: 640)
        }
    }
}
