//
//  ZebrunnerObserver.swift
//  
//
//  Created by Dzmitry Prymudrau on 22.07.22.
//

import Foundation
import XCTest

@available(iOS 10.0, *)
@available(macOS 10.12, *)
public class ZebrunnerObserver: NSObject, XCTestObservation {
    
    private var zebrunnerClient: ZebrunnerApiClient!
    private static var observer: ZebrunnerObserver!
    private var testSuiteDictionary: [String: [XCTest]] = [:]
    
    private init(baseUrl: String, projectKey: String, refreshToken: String) {
        super.init()
        self.zebrunnerClient = ZebrunnerApiClient.shared(baseUrl: baseUrl, projectKey: projectKey, refreshToken: refreshToken)
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    public static func setUp(baseUrl: String, projectKey: String, refreshToken: String) {
        if(observer == nil) {
            self.observer = ZebrunnerObserver(baseUrl: baseUrl, projectKey: projectKey, refreshToken: refreshToken)
        }
    }
    
    public func testBundleWillStart(_ testBundle: Bundle) {
        guard let testRunName = ProcessInfo.processInfo.environment["TEST_RUN_NAME"],
              !testRunName.isEmpty else {
            zebrunnerClient.startTestRun(testRunName: "Test Run")
            return
        }
        zebrunnerClient.startTestRun(testRunName: testRunName)
    }
    
    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        testSuiteDictionary[testSuite.name] = testSuite.tests
    }
    
    public func testCaseWillStart(_ testCase: XCTestCase) {
        let className = getTestSuiteName(for: testCase)
        zebrunnerClient.startTest(name: testCase.name, className: className, methodName: testCase.name)
    }
    
    public func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
        if let reason = issue.detailedDescription {
            zebrunnerClient.finishTest(result: "FAILED", reason: reason, name: testCase.name)
        }
        zebrunnerClient.finishTest(result: "FAILED", name: testCase.name)
    }
    
    public func testCase(_ testCase: XCTestCase, didRecord expectedFailure: XCTExpectedFailure) {
        print(expectedFailure)
    }
    
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        zebrunnerClient.finishTest(result: "PASSED", name: testCase.name)
    }
    
    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
        zebrunnerClient.finishTestRun()
    }
    
    private func getTestSuiteName(for testCase: XCTestCase) -> String? {
        for (suiteName, cases) in testSuiteDictionary {
            for test in cases {
                if test.name == testCase.name {
                    return suiteName
                }
            }
        }
        return "Unreconized"
    }
    
}
