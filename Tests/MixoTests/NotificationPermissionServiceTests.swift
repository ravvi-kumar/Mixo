import UserNotifications
import XCTest
@testable import Mixo

@MainActor
final class NotificationPermissionServiceTests: XCTestCase {
    func testRequestAuthorizationThrowsInUnsupportedExecutionContext() async {
        let service = NotificationPermissionService()

        do {
            _ = try await service.requestAuthorization()
            XCTFail("Expected unsupported execution context error")
        } catch let NotificationPermissionService.ServiceError.unsupportedExecutionContext(reason) {
            XCTAssertFalse(reason.isEmpty)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testCurrentStatusReturnsNotDeterminedInUnsupportedExecutionContext() async {
        let service = NotificationPermissionService()
        let status = await service.currentStatus()
        XCTAssertEqual(status, .notDetermined)
    }
}
