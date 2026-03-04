import AppKit
import SwiftUI

@MainActor
final class HeadsUpFloatingCountdownManager {
    fileprivate final class ContentModel: ObservableObject {
        @Published var title = "Break Soon"
        @Published var countdown = "00:10"
    }

    private let contentModel = ContentModel()
    private var panel: NSPanel?

    func show(remainingSeconds: Int, isLongBreak: Bool) {
        contentModel.title = isLongBreak ? "Long Break Soon" : "Break Soon"
        contentModel.countdown = Self.formatDuration(remainingSeconds)

        let panel = ensurePanel()
        position(panel)
        panel.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
    }

    private func ensurePanel() -> NSPanel {
        if let panel {
            return panel
        }

        let initialFrame = NSRect(x: 0, y: 0, width: 220, height: 84)
        let panel = NSPanel(
            contentRect: initialFrame,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.contentView = NSHostingView(rootView: HeadsUpFloatingCountdownView(model: contentModel))

        self.panel = panel
        return panel
    }

    private func position(_ panel: NSPanel) {
        let margin: CGFloat = 12
        let pointer = NSEvent.mouseLocation
        let currentScreen = NSScreen.screens.first { NSMouseInRect(pointer, $0.frame, false) } ?? NSScreen.main
        let visibleFrame = currentScreen?.visibleFrame ?? NSScreen.screens.first?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let size = panel.frame.size

        var origin = CGPoint(x: pointer.x + 16, y: pointer.y + 18)
        origin.x = min(max(origin.x, visibleFrame.minX + margin), visibleFrame.maxX - size.width - margin)
        origin.y = min(max(origin.y, visibleFrame.minY + margin), visibleFrame.maxY - size.height - margin)
        panel.setFrame(NSRect(origin: origin, size: size), display: true)
    }

    private static func formatDuration(_ totalSeconds: Int) -> String {
        let bounded = max(0, totalSeconds)
        let minutes = bounded / 60
        let seconds = bounded % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct HeadsUpFloatingCountdownView: View {
    @ObservedObject var model: HeadsUpFloatingCountdownManager.ContentModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(model.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
            Text(model.countdown)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}
