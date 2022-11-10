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
    private var outputObserver: OutputObserver!
    
    private init(configuration: Configuration) {
        super.init()
        self.zebrunnerClient = ZebrunnerApiClient.setUp(configuration: configuration)
        self.outputObserver = OutputObserver(launchMode: configuration.launchMode)
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    /// Creates instance of ZebrunnerObserver
    /// - Parameters:
    ///    - configuration: configuration information about reporting to Zebrunner
    public static func setUp(configuration: Configuration) {
        guard configuration.isReportingEnabled else {
            print("Reporting to Zebrunner is turned off")
            return
        }
        
        if (observer == nil) {
            self.observer = ZebrunnerObserver(configuration: configuration)
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

        startLogsCapture(testCase)
    }
    
    /// Executed when test case fails
    ///  - Parameters:
    ///    - testCase: object of XCTestCase with data about executed test case
    ///    - issue: contains data about issue that is cause of fail
    public func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
        NotificationCenter.default.post(name: .interruptionInCapturedLogs, object: issue)
        
        updateMaintainer(testCase)
        var failureDescription: String
        if let reason = issue.detailedDescription {
            failureDescription = reason
        } else {
            failureDescription = issue.compactDescription
        }
        if !failureDescription.isEmpty {
            zebrunnerClient.finishTest(result: TestStatus.failed,
                                       reason: failureDescription,
                                       name: testCase.name,
                                       endTime: Date().toString())
        } else {
            zebrunnerClient.finishTest(result: TestStatus.failed,
                                       name: testCase.name,
                                       endTime: Date().toString())
        }
    }
    
    /// Executed after finish of test case
    ///  - Parameters:
    ///     - testCase: object of XCTestCase with data about executed test case
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        updateMaintainer(testCase)
        finishLogsCapture(testCase)
        
        if testCase.testRun!.hasSucceeded && !testCase.testRun!.hasBeenSkipped {
            zebrunnerClient.finishTest(result: TestStatus.passed,
                                       name: testCase.name,
                                       endTime: Date().toString())
        }
        if testCase.testRun!.hasBeenSkipped {
            zebrunnerClient.finishTest(result: TestStatus.skipped,
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
        return "Unrecognized"
    }
    
    /// Updates maintainer for test case if this case inherits XCZebrunnerTestCase
    ///  - Parameters:
    ///     - testCase: object of executed test case
    private func updateMaintainer(_ testCase: XCTestCase) {
        let testData = TestData(name: testCase.name,
                                className: getTestSuiteName(for: testCase),
                                methodName: testCase.name,
                                maintainer: testCase.testMaintainer as String)
        zebrunnerClient.updateTest(testData: testData)
    }
    
    /// Starts capturing console output for test case. Should be called on testCaseWillStart event
    /// - Parameter testCase: object of executed test case
    private func startLogsCapture(_ testCase: XCTestCase) {
        outputObserver.startLogsCapture(testCase: testCase)
    }
    /// Finishes capturing console output. Should be called on testCaseDidFinish event
    /// - Parameter testCase: object of executed test case
    private func finishLogsCapture(_ testCase: XCTestCase) {
        outputObserver.finishLogsCapture(testCase: testCase)
    }
}
