import AppKit
import CoreGraphics
import Foundation

protocol FullscreenActivityServicing {
    func isFullscreenActive() -> Bool
}

struct FullscreenActivityService: FullscreenActivityServicing {
    private let coverageThreshold: CGFloat = 0.97

    func isFullscreenActive() -> Bool {
        let screens = NSScreen.screens
        guard !screens.isEmpty else {
            return false
        }

        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let raw = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return false
        }

        for window in raw {
            guard let layer = window[kCGWindowLayer as String] as? Int, layer == 0 else {
                continue
            }

            guard let alpha = window[kCGWindowAlpha as String] as? Double, alpha > 0.01 else {
                continue
            }

            guard let boundsDictionary = window[kCGWindowBounds as String] as? [String: Any] else {
                continue
            }

            guard let bounds = CGRect(dictionaryRepresentation: boundsDictionary as CFDictionary) else {
                continue
            }

            guard bounds.width > 300, bounds.height > 300 else {
                continue
            }

            if coversAnyScreenMostly(windowBounds: bounds, screens: screens) {
                return true
            }
        }

        return false
    }

    private func coversAnyScreenMostly(windowBounds: CGRect, screens: [NSScreen]) -> Bool {
        for screen in screens {
            let screenBounds = screen.frame
            let intersection = windowBounds.intersection(screenBounds)
            guard !intersection.isNull else {
                continue
            }

            let screenArea = max(screenBounds.width * screenBounds.height, 1)
            let coverage = (intersection.width * intersection.height) / screenArea
            if coverage >= coverageThreshold {
                return true
            }
        }

        return false
    }
}
