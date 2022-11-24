//
//  RegistrationObserver.swift
//  
//
//  Created by asukhodolova on 18.11.22.
//

import Foundation
import XCTest

protocol RegistrationObserverProtocol {
    
    func onBeforeTestStart(_ testCase: XCTestCase)
    
    func onAfterTestStart(_ testCase: XCTestCase)
    
    func onBeforeTestFinish(_ testCase: XCTestCase)
    
    func onBeforeTestPass()
    
    func onBeforeTestFail(issue: XCTIssue?)
    
    func onBeforeTestSkip()
    
    func onAfterTestFinish(_ testCase: XCTestCase)
    
    func onAfterTestPass()
    
    func onAfterTestFail(issue: XCTIssue?)
    
    func onAfterTestSkip()
}

class RegistrationObserver: RegistrationObserverProtocol {
    
    private static var instance: RegistrationObserver!
    private var configuration: Configuration!
    private var outputObserver: OutputObserver!
    
    private init(configuration: Configuration) {
        self.configuration = configuration
        self.outputObserver = OutputObserver(isDebugLogsEnabled: configuration.isDebugLogsEnabled)
    }
    
    public static func setUp(configuration: Configuration) -> RegistrationObserver? {
        if (self.instance == nil) {
            self.instance = RegistrationObserver(configuration: configuration)
        }
        return instance
    }
    
    public static func getInstance() throws -> RegistrationObserver {
        guard let instance = RegistrationObserver.instance else {
            throw ZebrunnerAgentError(description: "There was no instance of RegistrationObserver created")
        }
        return instance
    }
    
    func onBeforeTestStart(_ testCase: XCTestCase) {}
    
    func onAfterTestStart(_ testCase: XCTestCase) {
        startLogsCapture(testCase)
    }
    
    func onBeforeTestFinish(_ testCase: XCTestCase) {
        finishLogsCapture(testCase)
        
        let status = getTestCaseStatus(testCase)
        if (status == TestStatus.passed) {
            onBeforeTestPass()
        } else if (status == TestStatus.failed) {
            onBeforeTestFail(issue: nil)
        } else if (status == TestStatus.skipped) {
            onBeforeTestSkip()
        }
    }
    
    func onBeforeTestPass() {
        TestCasesRegistry.getInstance().setExplicitStatusesOnCurrentTest(testCaseStatus: configuration.testCaseStatusOnPass)
    }
    
    func onBeforeTestFail(issue: XCTIssue?) {
        if let issue = issue {
            suspendLogsCapture(issue)
        } else {
            TestCasesRegistry.getInstance().setExplicitStatusesOnCurrentTest(testCaseStatus: configuration.testCaseStatusOnFail)
        }
    }
    
    func onBeforeTestSkip() {
        TestCasesRegistry.getInstance().setExplicitStatusesOnCurrentTest(testCaseStatus: configuration.testCaseStatusOnSkip)
    }
    
    func onAfterTestFinish(_ testCase: XCTestCase) {
        let status = getTestCaseStatus(testCase)
        if (status == TestStatus.passed) {
            onAfterTestPass()
        } else if (status == TestStatus.failed) {
            onAfterTestFail(issue: nil)
        } else if (status == TestStatus.skipped) {
            onAfterTestSkip()
        }
    }
    
    func onAfterTestPass() {}
    
    func onAfterTestFail(issue: XCTIssue?) {}
    
    func onAfterTestSkip() {}
    
    /// Gets test case execution status
    /// - Parameter testCase: test case object
    /// - Returns: TestStatus
    private func getTestCaseStatus(_ testCase: XCTestCase) -> TestStatus {
        var status = testCase.testRun!.hasSucceeded ? TestStatus.passed : TestStatus.failed
        if testCase.testRun!.hasBeenSkipped {
            status = configuration.skipsAsFailures ? TestStatus.failed : TestStatus.skipped
        }
        return status
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
