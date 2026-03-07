import AppKit
import SwiftUI

@MainActor
final class OverlayWindowManager {
    struct Diagnostics {
        let screenCount: Int
        let windowCount: Int
        let mode: String
    }

    private enum PresentationMode {
        case hidden
        case preview
        case breakCountdown
    }

    fileprivate final class OverlayContentModel: ObservableObject {
        @Published var title = "Time for an eye break"
        @Published var subtitle = "Look at something far away for 20 seconds"
        @Published var countdown = "00:20"
        @Published var showsCountdown = true
    }

    private var windowsByScreenID: [String: NSWindow] = [:]
    private let contentModel = OverlayContentModel()
    private var presentationMode: PresentationMode = .hidden
    private var localKeyMonitor: Any?
    private var globalKeyMonitor: Any?
    private var emergencyDismissHandler: (() -> Void)?
    private var lastEmergencyDismissAt = Date.distantPast
    private let logger = AppLogger.make("overlay")

    func setEmergencyDismissHandler(_ handler: @escaping () -> Void) {
        emergencyDismissHandler = handler
    }

    func diagnostics() -> Diagnostics {
        Diagnostics(
            screenCount: NSScreen.screens.count,
            windowCount: windowsByScreenID.count,
            mode: modeString
        )
    }

    func showPreviewOverlay() {
        configurePreview()
        let didChangeScreens = syncWindowsForCurrentScreens()
        if presentationMode != .preview || didChangeScreens {
            bringWindowsToFront()
        }
        startEmergencyDismissMonitorsIfNeeded()

        if presentationMode != .preview {
            logger.info("overlay_preview_shown windows=\(self.windowsByScreenID.count)")
        }
        presentationMode = .preview
    }

    func showBreakOverlay(remainingSeconds: Int) {
        configureBreak(remainingSeconds: remainingSeconds)
        let didChangeScreens = syncWindowsForCurrentScreens()
        if presentationMode != .breakCountdown || didChangeScreens {
            bringWindowsToFront()
        }
        startEmergencyDismissMonitorsIfNeeded()

        if presentationMode != .breakCountdown {
            logger.info("overlay_break_shown windows=\(self.windowsByScreenID.count)")
        }
        presentationMode = .breakCountdown
    }

    func hideOverlay() {
        guard !windowsByScreenID.isEmpty || presentationMode != .hidden else {
            return
        }

        for window in windowsByScreenID.values {
            window.close()
        }
        windowsByScreenID.removeAll()
        stopEmergencyDismissMonitors()
        presentationMode = .hidden
        logger.info("overlay_hidden")
    }

    private func makeWindow(for screen: NSScreen) -> NSWindow {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        window.setFrame(screen.frame, display: true)
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.backgroundColor = .clear
        window.isOpaque = false
        window.ignoresMouseEvents = true
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: OverlayContentView(model: contentModel))
        return window
    }

    @discardableResult
    private func syncWindowsForCurrentScreens() -> Bool {
        var changed = false
        let screens = NSScreen.screens
        let screenIDs = Set(screens.map { identifier(for: $0) })

        let staleIDs = windowsByScreenID.keys.filter { !screenIDs.contains($0) }
        for staleID in staleIDs {
            windowsByScreenID[staleID]?.close()
            windowsByScreenID.removeValue(forKey: staleID)
            changed = true
        }

        for screen in screens {
            let screenID = identifier(for: screen)
            if let existing = windowsByScreenID[screenID] {
                if existing.frame != screen.frame {
                    existing.setFrame(screen.frame, display: true)
                    changed = true
                }
                continue
            }

            let window = makeWindow(for: screen)
            windowsByScreenID[screenID] = window
            changed = true
        }

        return changed
    }

    private func bringWindowsToFront() {
        for window in windowsByScreenID.values {
            window.orderFrontRegardless()
        }
    }

    private func startEmergencyDismissMonitorsIfNeeded() {
        if localKeyMonitor == nil {
            localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self else {
                    return event
                }
                if self.handleEmergencyDismissKey(event.keyCode) {
                    return nil
                }
                return event
            }
        }

        if globalKeyMonitor == nil {
            globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
                _ = self?.handleEmergencyDismissKey(event.keyCode)
            }
        }
    }

    private func stopEmergencyDismissMonitors() {
        if let localKeyMonitor {
            NSEvent.removeMonitor(localKeyMonitor)
            self.localKeyMonitor = nil
        }
        if let globalKeyMonitor {
            NSEvent.removeMonitor(globalKeyMonitor)
            self.globalKeyMonitor = nil
        }
    }

    @discardableResult
    private func handleEmergencyDismissKey(_ keyCode: UInt16) -> Bool {
        // Escape key: emergency dismiss path during active overlay.
        guard keyCode == 53 else {
            return false
        }

        let now = Date()
        // Local + global monitors can both fire on one keypress; debounce to one action.
        if now.timeIntervalSince(lastEmergencyDismissAt) < 0.3 {
            return true
        }
        lastEmergencyDismissAt = now

        logger.info("overlay_emergency_dismiss_key")
        emergencyDismissHandler?()
        return true
    }

    private func configurePreview() {
        contentModel.title = "Relax those eyes"
        contentModel.subtitle = "Set your eyes on something distant until the countdown is over"
        contentModel.countdown = "00:20"
        contentModel.showsCountdown = true
    }

    private func configureBreak(remainingSeconds: Int) {
        contentModel.title = "Relax those eyes"
        contentModel.subtitle = "Set your eyes on something distant until the countdown is over"
        contentModel.countdown = Self.formatDuration(remainingSeconds)
        contentModel.showsCountdown = true
    }

    private var modeString: String {
        switch presentationMode {
        case .hidden:
            return "hidden"
        case .preview:
            return "preview"
        case .breakCountdown:
            return "breakCountdown"
        }
    }

    private static func formatDuration(_ totalSeconds: Int) -> String {
        let bounded = max(0, totalSeconds)
        let minutes = bounded / 60
        let seconds = bounded % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func identifier(for screen: NSScreen) -> String {
        let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
        return number?.stringValue ?? String(describing: ObjectIdentifier(screen))
    }
}

private struct OverlayContentView: View {
    @ObservedObject var model: OverlayWindowManager.OverlayContentModel

    var body: some View {
        GeometryReader { geometry in
            let contentWidth = min(geometry.size.width * 0.76, 1260)
            let titleSize = min(max(34, geometry.size.width * 0.05), 72)
            let subtitleSize = min(max(18, geometry.size.width * 0.022), 40)
            let countdownSize = min(max(46, geometry.size.width * 0.05), 90)

            ZStack {
                OverlayBlurView()
                    .ignoresSafeArea()

                Color.black.opacity(0.14)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Text("Current time is \(Self.currentTimeString())")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.86))
                        .padding(.top, max(42, geometry.size.height * 0.085))

                    Spacer()

                    VStack(spacing: 22) {
                        Text(model.title)
                            .font(.system(size: titleSize, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text(model.subtitle)
                            .font(.system(size: subtitleSize, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        Capsule()
                            .fill(Color.white.opacity(0.28))
                            .frame(width: 190, height: 2)
                            .padding(.top, 4)

                        if model.showsCountdown {
                            Text(model.countdown)
                                .font(.system(size: countdownSize, weight: .heavy, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white.opacity(0.98))
                                .padding(.top, 8)
                        }
                    }
                    .frame(width: contentWidth)

                    Spacer()

                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            overlayActionPill(title: "Skip", systemName: "chevron.forward.2")
                            overlayActionPill(title: "Lock Screen", systemName: "lock")
                        }

                        Text("Press Esc twice to skip")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.62))
                    }
                    .padding(.bottom, max(36, geometry.size.height * 0.09))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func overlayActionPill(title: String, systemName: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
        }
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.2))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    private static func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

private struct OverlayBlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .fullScreenUI
        view.state = .active
        view.blendingMode = .behindWindow
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.state = .active
    }
}
