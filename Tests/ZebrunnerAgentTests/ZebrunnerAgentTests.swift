import XCTest
import ZebrunnerAgent

final class ZebrunnerAgentTests: XCTestCase {
    func testZebrunnerApiClient() throws {
        let client = ZebrunnerApiClient.shared
        client.startTestRun(projectKey: "IOS", testRunName: "TEST RUN")
        client.startTest(name: "testZebrunnerApiClient", className: "ZebrunnerAgentTests", methodName: "testZebrunnerApiClient")
        client.finishTest(result: "PASSED", name: "testZebrunnerApiClient")
        client.finishTestRun()
    }
}
