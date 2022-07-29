import XCTest
import ZebrunnerAgent

final class ZebrunnerAgentTests: XCTestCase {
    func testMaintainerAnonymous() throws {
        XCTAssert(testMaintainer == "anonymous", "testMaintainer variable isn't \(testMaintainer)")
    }
    
    func testMaintainerIsSet() throws {
        testMaintainer = "dprymudrau"
        XCTAssert(testMaintainer == "dprymudrau", "testMaintainer variable isn't \(testMaintainer)")
    }
}
