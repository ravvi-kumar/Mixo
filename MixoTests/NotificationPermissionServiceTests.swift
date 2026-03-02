import UserNotifications
import XCTest
@testable import Mixo

@MainActor
final class NotificationPermissionServiceTests: XCTestCase {
    func testCurrentStatusReturnsKnownAuthorizationState() async {
        let service = NotificationPermissionService()
        let status = await service.currentStatus()
        switch status {
        case .notDetermined, .denied, .authorized, .provisional, .ephemeral:
            XCTAssertTrue(true)
        @unknown default:
            XCTFail("Unexpected authorization status: \(status.rawValue)")
        }
    }
}
