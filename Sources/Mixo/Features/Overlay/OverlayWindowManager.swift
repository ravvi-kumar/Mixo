import AppKit
import SwiftUI

@MainActor
final class OverlayWindowManager {
    private var windowsByScreenID: [String: NSWindow] = [:]
    private let logger = AppLogger.make("overlay")

    func showPreviewOverlay() {
        for screen in NSScreen.screens {
            let screenID = identifier(for: screen)
            if let existing = windowsByScreenID[screenID] {
                existing.orderFrontRegardless()
                continue
            }

            let window = makeWindow(for: screen)
            windowsByScreenID[screenID] = window
            window.orderFrontRegardless()
        }

        logger.info("overlay_preview_shown windows=\(self.windowsByScreenID.count)")
    }

    func hideOverlay() {
        for window in windowsByScreenID.values {
            window.close()
        }
        windowsByScreenID.removeAll()
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
        window.contentView = NSHostingView(rootView: OverlayPreviewView())
        return window
    }

    private func identifier(for screen: NSScreen) -> String {
        let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
        return number?.stringValue ?? String(describing: ObjectIdentifier(screen))
    }
}

private struct OverlayPreviewView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.62)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "eye")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("Time for an eye break")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Look at something far away for 20 seconds")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
            }
            .multilineTextAlignment(.center)
            .padding(24)
        }
    }
}
