//
//  ZebrunnerObserver.swift
//  
//
//  Created by Dzmitry Prymudrau on 22.07.22.
//

import Foundation
import XCTest

public class ZebrunnerObserver: NSObject, XCTestObservation {
    
    private var zebrunnerClient: ZebrunnerApiClient!
    private static var observer: ZebrunnerObserver!
    private var testSuiteDictionary: [String: [XCTest]] = [:]
    
    private init(baseUrl: String, projectKey: String, refreshToken: String) {
        super.init()
        self.zebrunnerClient = ZebrunnerApiClient.setUp(baseUrl: baseUrl, projectKey: projectKey, refreshToken: refreshToken)
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    /// Creates instanse of ZebrunerObserver
    /// - Parameters:
    ///    - baseUrl: Zebrunner tenant base url
    ///    - projectKey: the project this test run belongs to
    ///    - refreshToken: needed for exchanging for a short living access token to perform future manipulations
    public static func setUp(baseUrl: String, projectKey: String, refreshToken: String) {
        if(observer == nil) {
            self.observer = ZebrunnerObserver(baseUrl: baseUrl, projectKey: projectKey, refreshToken: refreshToken)
        }
    }
    
    /// Executed befire test bundle started and creates new Test Run on Zebrunner
    ///  - Parameters:
    ///    - testBundle: object of Bundle
    public func testBundleWillStart(_ testBundle: Bundle) {
        guard let testRunName = ProcessInfo.processInfo.environment["TEST_RUN_NAME"],
              !testRunName.isEmpty else {
            zebrunnerClient.startTestRun(testRunName: "Test Run", startTime: Date().toString())
            return
        }
        zebrunnerClient.startTestRun(testRunName: testRunName, startTime: Date().toString())
    }
    
    /// Executed on start of each Test Class used for saving name of classes and tests inside
    ///  - Parameters:
    ///     - testSuite: object of XCTestSuite that will be executed
    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        testSuiteDictionary[testSuite.name] = testSuite.tests
    }
    
    /// Executed before Test Case started used to register test executin start on Zebrunner
    ///  - Parameters:
    ///     - testCase: object of XCTestCase with data about executed test case
    public func testCaseWillStart(_ testCase: XCTestCase) {
        let className = getTestSuiteName(for: testCase)
        
        let testData = TestData(name: testCase.name,
                                className: className,
                                methodName: testCase.name)
        zebrunnerClient.startTest(testData: testData, startTime: Date().toString())
    }
    
    /// Executed when test case fails
    ///  - Parameters:
    ///    - testCase: object of XCTestCase with data about executed test case
    ///    - issue: contains data about issue that is cause of fail
    public func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
        updateMaintainer(testCase)
        var failureDescription: String
        if let reason = issue.detailedDescription {
            failureDescription = reason
        } else {
            failureDescription = issue.compactDescription
        }
        if !failureDescription.isEmpty {
            zebrunnerClient.finishTest(result: "FAILED",
                                       reason: failureDescription,
                                       name: testCase.name,
                                       endTime: Date().toString())
        } else {
            zebrunnerClient.finishTest(result: "FAILED",
                                       name: testCase.name,
                                       endTime: Date().toString())
        }
    }
    
    /// Executed after finish of test case
    ///  - Parameters:
    ///     - testCase: object of XCTestCase with data about executed test case
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        updateMaintainer(testCase)
        if testCase.testRun!.hasSucceeded {
            
            zebrunnerClient.finishTest(result: "PASSED",
                                       name: testCase.name,
                                       endTime: Date().toString())
        }
    }
    
    /// Executed after Test Class finished execution
    ///  - Parameters:
    ///     - testSuite: object of XCTestSuite that executed
    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        testSuiteDictionary.removeValue(forKey: testSuite.name)
    }
    
    
    /// Executed after finish of executed test suite
    /// - Parameters:
    ///  - testBundle: object of Bundle
    public func testBundleDidFinish(_ testBundle: Bundle) {
        zebrunnerClient.finishTestRun(endTime: Date().toString())
    }
    
    
    /// Returns TestClass name for given test case
    /// - Parameters:
    ///   - testCase: object of executed test case
    private func getTestSuiteName(for testCase: XCTestCase) -> String {
        for (suiteName, cases) in testSuiteDictionary {
            for test in cases {
                if test.name == testCase.name {
                    return suiteName
                }
            }
        }
        return "Unreconized"
    }
    
    /// Updates maintainer for test case if this case inherits XCZebrunnerTestCase
    ///  - Parameters:
    ///     - testCase: object of executed test case
    private func updateMaintainer(_ testCase: XCTestCase) {
        let testData = TestData(name: testCase.name,
                                className: getTestSuiteName(for: testCase),
                                methodName: testCase.name,
                                maintainer: testCase.methodMaintainer as String)
        zebrunnerClient.updateTest(testData: testData)
    }
    
}

/// Extension needed for getting Date in ISO8601 timestamp with an offset from UTC
extension Date {
    func toString(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ") -> String{
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
}
