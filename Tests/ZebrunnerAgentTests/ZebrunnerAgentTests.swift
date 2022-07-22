import XCTest
import ZebrunnerAgent

final class ZebrunnerAgentTests: XCTestCase {
    func testZebrunnerApiClient() throws {
        ZebrunnerObserver.setUp(baseUrl: "", projectKey: "", refreshToken: "")
    }
}
