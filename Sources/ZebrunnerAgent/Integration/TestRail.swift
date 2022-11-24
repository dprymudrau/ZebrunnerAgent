//
//  TestRail.swift
//  
//
//  Created by asukhodolova on 18.11.22.
//

import Foundation

public class TestRail {
    
    public enum SystemTestCaseStatus {
        public static let passed = "passed"
        public static let blocked = "blocked"
        public static let retest = "retest"
        public static let failed = "failed"
    }
    
    static let syncEnabledKey = "com.zebrunner.app/tcm.testrail.sync.enabled"
    static let syncRealTimeKey = "com.zebrunner.app/tcm.testrail.sync.real-time"
    static let includeAllKey = "com.zebrunner.app/tcm.testrail.include-all-cases"
    static let suiteIdKey = "com.zebrunner.app/tcm.testrail.suite-id"
    static let runIdKey = "com.zebrunner.app/tcm.testrail.run-id"
    static let runNameKey = "com.zebrunner.app/tcm.testrail.run-name"
    static let milestoneKey = "com.zebrunner.app/tcm.testrail.milestone"
    static let assigneeKey = "com.zebrunner.app/tcm.testrail.assignee"
    
    private init() {}
    
    /// Mandatory.
    /// Sets TestRail suite id for current test run. This method must be invoked before all tests
    /// - Parameter suiteId: TestRail suite id
    public static func setSuiteId(suiteId: String) {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: suiteIdKey, value: suiteId)
    }
    
    
    /// Mandatory.
    /// Sets TestRail's case associated with specific automated test
    /// - Parameter testCaseId: TestRail test case id
    public static func setTestCaseId(testCaseId: String) {
        TestCasesRegistry.getInstance().addTestCasesToCurrentTest(tcmType: TcmType.testRail, testCaseIds: [testCaseId])
    }
    
    /// Sets the given status for the given test case in TestRail run
    ///
    /// If you need to use a custom status, contact your TestRail administrator to get the correct system name for your desired status.
    /// - Parameters:
    ///   - testCaseId: TestRail id of the test case. Can be either a regular number or a number with the letter 'C' at the beggining.
    ///   - resultStatus: resultStatus system name (not labels!) of the status to be set for the test case
    ///
    /// - seealso TestRail.SystemTestCaseStatus
    public static func setTestCaseStatus(testCaseId: String, resultStatus: String) {
        TestCasesRegistry.getInstance().setCurrentTestTestCaseStatus(tcmType: TcmType.testRail,
                                                                     testCaseId: testCaseId,
                                                                     status: resultStatus)
    }
    
    /// Optional.
    /// Disables result upload. Same as #setSuiteId(String), this method must be invoked before all tests
    public static func disableSync() {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: syncEnabledKey, value: "false")
    }
    
    /// Optional.
    /// Includes all cases from suite into newly created run in TestRail. Same as #setSuiteId(String), this method must be invoked before all tests
    public static func includeAllTestCasesInNewRun() {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: includeAllKey, value: "true")
    }
    
    /// Optional.
    /// Enables real-time results upload. In this mode, result of test execution will be uploaded immediately after test finish. This method also automatically invokes
    /// #includeAllTestCasesInNewRun(). Same as #setSuiteId(String), this method must be invoked before all tests
    public static func enableRealTimeSync() {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: syncRealTimeKey, value: "true")
        Label.attachToTestRun(key: includeAllKey, value: "true")
    }
    
    /// Optional.
    /// Adds result into existing TestRail run. If not provided, test run is treated as new. Same as #setSuiteId(String), this method must be invoked before all tests
    /// - Parameter runId: TestRail run id
    public static func setRunId(runId: String) {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: runIdKey, value: runId)
    }
    
    /// Optional.
    /// Sets custom name for new TestRail run. By default, Zebrunner test run name is used. Same as #setSuiteId(String), this method must be invoked before all tests
    /// - Parameter runName: TestRail run name
    public static func setRunName(runName: String) {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: runNameKey, value: runName)
    }
    
    /// Optional.
    /// Adds result in TestRail milestone with the given name. Same as #setSuiteId(String), this method must be invoked before all tests
    /// - Parameter milestone: TestRail milestone
    public static func setMilestone(milestone: String) {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: milestoneKey, value: milestone)
    }
    
    /// Optional.
    /// Sets TestRail run assignee. Same as #setSuiteId(String), this method must be invoked before all tests
    /// - Parameter assignee: TestRail assignee
    public static func setAssignee(assignee: String) {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: assigneeKey, value: assignee)
    }
    
    private static func noExecutedTests() -> Bool {
        let hasTests = RunContext.getInstance().hasTests()
        if (hasTests) {
            print("The TestRail configuration must be provided before start of tests.\nHint: move the configuration to the code block which is executed before all tests")
        }
        return !hasTests
    }
}
