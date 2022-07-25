import XCTest
import ZebrunnerAgent

final class ZebrunnerAgentTests: XCZebrunnerTestCase {
    func testMaintainerAnonymous() throws {
        XCTAssert(methodMaintainer == "anonymous", "methodMaintainer variable isn't \(methodMaintainer)")
    }
    
    func testMaintainerIsSet() throws {
        methodMaintainer = "johndoe"
        XCTAssert(methodMaintainer == "johndoe", "methodMaintainer variable isn't \(methodMaintainer)")
    }
}
