import XCTest
import ZebrunnerAgent

final class ZebrunnerAgentTests: XCTestCase {
    func testMaintainerAnonymous() throws {
        XCTAssert(methodMaintainer == "anonymous", "methodMaintainer variable isn't \(methodMaintainer)")
    }
    
    func testMaintainerIsSet() throws {
        methodMaintainer = "dprymudrau"
        XCTAssert(methodMaintainer == "dprymudrau", "methodMaintainer variable isn't \(methodMaintainer)")
    }
}
