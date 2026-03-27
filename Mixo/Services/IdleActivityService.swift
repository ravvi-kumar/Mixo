import CoreGraphics
import Foundation

protocol IdleActivityServicing {
    func idleDurationSeconds() -> TimeInterval
}

struct IdleActivityService: IdleActivityServicing {
    // `.null` does not reflect user interaction reliably for our app context.
    // Track a representative set of keyboard/mouse input event types and use the
    // most recent one as the session idle value.
    private let monitoredEventTypes: [CGEventType] = [
        .keyDown,
        .flagsChanged,
        .leftMouseDown,
        .leftMouseUp,
        .leftMouseDragged,
        .rightMouseDown,
        .rightMouseUp,
        .rightMouseDragged,
        .otherMouseDown,
        .otherMouseUp,
        .otherMouseDragged,
        .mouseMoved,
        .scrollWheel
    ]

    func idleDurationSeconds() -> TimeInterval {
        var mostRecentIdle = TimeInterval.greatestFiniteMagnitude

        for eventType in monitoredEventTypes {
            let idle = CGEventSource.secondsSinceLastEventType(
                .hidSystemState,
                eventType: eventType
            )
            guard idle.isFinite else {
                continue
            }
            mostRecentIdle = min(mostRecentIdle, idle)
        }

        guard mostRecentIdle.isFinite else {
            return 0
        }
        return max(0, mostRecentIdle)
    }
}
