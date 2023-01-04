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
    private var registrationObserver: RegistrationObserver!
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
        registrationObserver = RegistrationObserver.setUp(configuration: configuration)
        
        let requestData = TestRunStartDTO(name: configuration.displayName,
                                          startTime: Date().toISO8601FormattedString(),
                                          config: configuration.config,
                                          milestone: configuration.milestone,
                                          notifications: configuration.notifications)
        if let response = zebrunnerClient.startTestRun(testRunStartRequest: requestData) {
            RunContext.getInstance().setTestRunId(testRunId: response.id)
            
            updateLocale(locale: configuration.locale)
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
        registrationObserver.onBeforeTestStart(testCase)
        
        let requestData = TestCaseStartDTO(name: testCase.name,
                                           className: getTestSuiteName(for: testCase),
                                           methodName: testCase.name,
                                           startTime: Date().toISO8601FormattedString())
        if let response = zebrunnerClient.startTest(testCaseStartRequest: requestData) {
            RunContext.getInstance().addTestCase(testCaseName: response.name,
                                                 testCaseId: response.id)
        }
        
        registrationObserver.onAfterTestStart(testCase)
    }
    
    /// Executes when test case fails
    ///  - Parameters:
    ///    - testCase: object of XCTestCase with data about executed test case
    ///    - issue: contains data about issue that causes a fail
    public func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
        registrationObserver.onBeforeTestFail(issue: issue)
        
        updateMaintainer(testCase)
        var failureDescription: String
        if let reason = issue.detailedDescription {
            failureDescription = reason
        } else {
            failureDescription = issue.compactDescription
        }
        let requestData = TestCaseFinishDTO(result: TestStatus.failed,
                                            endTime: Date().toISO8601FormattedString(),
                                            reason: failureDescription)
        zebrunnerClient.finishTest(testCaseName: testCase.name, testCaseFinishRequest: requestData)
        
        registrationObserver.onAfterTestFail(issue: issue)
    }
    
    /// Executes after finish of test case
    ///  - Parameters:
    ///     - testCase: object of XCTestCase with data about executed test case
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        registrationObserver.onBeforeTestFinish(testCase)
        
        updateMaintainer(testCase)
        if testCase.testRun!.hasSucceeded {
            var status = TestStatus.passed
            if testCase.testRun!.hasBeenSkipped {
                status = configuration.skipsAsFailures ? TestStatus.failed : TestStatus.skipped
            }
            let requestData = TestCaseFinishDTO(result: status,
                                                endTime: Date().toISO8601FormattedString())
            zebrunnerClient.finishTest(testCaseName: testCase.name, testCaseFinishRequest: requestData)
        }
        RunContext.getInstance().finishTestCase()
        
        registrationObserver.onAfterTestFinish(testCase)
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
        let requestData = TestRunFinishDTO(endTime: Date().toISO8601FormattedString())
        zebrunnerClient.finishTestRun(testRunFinishRequest: requestData)
        RunContext.getInstance().finishTestRun()
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
    
    /// Updates locale for test run
    /// - Parameter locale: locale
    private func updateLocale(locale: String?) {
        if let locale = locale {
            Locale.setLocale(localeValue: locale)
        }
    }
}
