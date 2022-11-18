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
    private var testSuiteDictionary: [String: [XCTest]] = [:]
    private var outputObserver: OutputObserver!
    private var configuration: Configuration!
    
    public override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    /// Reads configuration information according to priority:
    /// 1. environment variables
    /// 2. properties from Info.plist
    /// - Parameter testBundle: current test bundle
    /// - Returns: configuration information
    private func readConfiguration(_ testBundle: Bundle) -> Configuration {
        var configuration = try! EnvironmentConfigurationProvider().getConfiguration()
        if configuration == nil {
            configuration = try! PropertiesConfigurationProvider(testBundle: testBundle).getConfiguration()
        }
        return (configuration != nil) ? configuration! : Configuration(isReportingEnabled: false)
    }
    
    /// Executes before test bundle started and creates a new Test Run on Zebrunner
    ///  - Parameters:
    ///    - testBundle: object of Bundle
    public func testBundleWillStart(_ testBundle: Bundle) {
        configuration = readConfiguration(testBundle)
        guard configuration.isReportingEnabled else {
            XCTestObservationCenter.shared.removeTestObserver(self)
            return
        }
        
        zebrunnerClient = ZebrunnerApiClient.setUp(configuration: configuration)
        outputObserver = OutputObserver(isDebugLogsEnabled: configuration.isDebugLogsEnabled)
        
        let requestData = TestRunStartDTO(name: configuration.displayName,
                                          startTime: Date().toString(),
                                          config: configuration.config,
                                          milestone: configuration.milestone,
                                          notifications: configuration.notifications)
        zebrunnerClient.startTestRun(testRunStartRequest: requestData)
        
        if let locale = configuration.locale {
            Locale.setLocale(localeValue: locale)
        }
    }
    
    /// Executes on start of each Test Class used for saving name of classes and tests inside
    ///  - Parameters:
    ///     - testSuite: object of XCTestSuite that will be executed
    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        testSuiteDictionary[testSuite.name] = testSuite.tests
    }
    
    /// Executes before Test Case started used to register test execution start on Zebrunner
    ///  - Parameters:
    ///     - testCase: object of XCTestCase with data about executed test case
    public func testCaseWillStart(_ testCase: XCTestCase) {
        let requestData = TestCaseStartDTO(name: testCase.name,
                                           className: getTestSuiteName(for: testCase),
                                           methodName: testCase.name,
                                           startTime: Date().toString())
        zebrunnerClient.startTest(testCaseStartRequest: requestData)
        
        startLogsCapture(testCase)
    }
    
    /// Executes when test case fails
    ///  - Parameters:
    ///    - testCase: object of XCTestCase with data about executed test case
    ///    - issue: contains data about issue that causes a fail
    public func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
        suspendLogsCapture(issue)
        updateMaintainer(testCase)
        
        var failureDescription: String
        if let reason = issue.detailedDescription {
            failureDescription = reason
        } else {
            failureDescription = issue.compactDescription
        }
        let requestData = TestCaseFinishDTO(result: TestStatus.failed,
                                            endTime: Date().toString(),
                                            reason: failureDescription)
        zebrunnerClient.finishTest(testCaseName: testCase.name, testCaseFinishRequest: requestData)
    }
    
    /// Executes after finish of test case
    ///  - Parameters:
    ///     - testCase: object of XCTestCase with data about executed test case
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        finishLogsCapture(testCase)
        updateMaintainer(testCase)
        
        if testCase.testRun!.hasSucceeded && !testCase.testRun!.hasBeenSkipped {
            let requestData = TestCaseFinishDTO(result: TestStatus.passed,
                                                endTime: Date().toString())
            zebrunnerClient.finishTest(testCaseName: testCase.name, testCaseFinishRequest: requestData)
        }
        if testCase.testRun!.hasBeenSkipped {
            let result = configuration.skipsAsFailures ? TestStatus.failed : TestStatus.skipped
            let requestData = TestCaseFinishDTO(result: result,
                                                endTime: Date().toString())
            zebrunnerClient.finishTest(testCaseName: testCase.name, testCaseFinishRequest: requestData)
        }
    }
    
    /// Executes after Test Class finished execution
    ///  - Parameters:
    ///     - testSuite: object of XCTestSuite that executed
    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        testSuiteDictionary.removeValue(forKey: testSuite.name)
    }
    
    
    /// Executes after finish of executed test suite
    /// - Parameters:
    ///  - testBundle: object of Bundle
    public func testBundleDidFinish(_ testBundle: Bundle) {
        let requestData = TestRunFinishDTO(endTime: Date().toString())
        zebrunnerClient.finishTestRun(testRunFinishRequest: requestData)
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
    
    /// Updates maintainer for test case
    ///  - Parameters:
    ///     - testCase: object of executed test case
    private func updateMaintainer(_ testCase: XCTestCase) {
        let requestData = TestCaseUpdateDTO(name: testCase.name,
                                            className: getTestSuiteName(for: testCase),
                                            methodName: testCase.name,
                                            maintainer: testCase.testMaintainer as String)
        zebrunnerClient.updateTest(testCaseUpdateRequest: requestData)
    }
    
    /// Notifies OutputObserver that test case has an error and reports it
    /// - Parameter issue: caused issue of failed test case
    private func suspendLogsCapture(_ issue: XCTIssue){
        NotificationCenter.default.post(name: .interruptionInCapturedLogs, object: issue)
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
