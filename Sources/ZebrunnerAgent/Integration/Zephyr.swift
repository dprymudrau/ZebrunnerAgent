//
//  Zephyr.swift
//  
//
//  Created by asukhodolova on 18.11.22.
//

import Foundation

public class Zephyr {
    
    public class Scale {
        public class SystemTestCaseStatus {
            public enum Cloud {
                public static let inProgress = "IN PROGRESS"
                public static let pass = "PASS"
                public static let fail = "FAIL"
                public static let notExecuted = "NOT EXECUTED"
                public static let blocked = "BLOCKED"
            }
        }
    }
    
    public class Squad {
        public class SystemTestCaseStatus {
            public enum Cloud {
                public static let unexecuted = "UNEXECUTED"
                public static let pass = "PASS"
                public static let fail = "FAIL"
                public static let wip = "WIP"
                public static let blocked = "BLOCKED"
            }
        }
    }
    
    static let syncEnabledKey = "com.zebrunner.app/tcm.zephyr.sync.enabled"
    static let syncRealTimeKey = "com.zebrunner.app/tcm.zephyr.sync.real-time"
    static let testCycleKey = "com.zebrunner.app/tcm.zephyr.test-cycle-key"
    static let jiraProjectKey = "com.zebrunner.app/tcm.zephyr.jira-project-key"
    
    private init() {}
    
    /// Mandatory.
    /// The method sets Zephyr test cycle key. This method must be invoked before all tests
    /// - Parameter testKey: Zephyr test cycle key
    public static func setTestCycleKey(testKey: String) {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: testCycleKey, value: testKey)
    }
    
    /// Mandatory.
    /// Sets Zephyr Jira project key. Same as #setTestCycleKey(String), this method must be invoked before all tests
    /// - Parameter jiraKey: Zephyr Jira project key
    public static func setJiraProjectKey(jiraKey: String) {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: jiraProjectKey, value: jiraKey)
    }
    
    /// Mandatory.
    /// Using these mechanisms you can set test case keys associated with specific automated test
    /// - Parameter testCaseKey: Zephyr test case key
    public static func setTestCaseKey(testCaseKey: String) {
        TestCasesRegistry.getInstance().addTestCasesToCurrentTest(tcmType: TcmType.zephyr, testCaseIds: [testCaseKey])
    }
    
    /// Sets the given status for the given test in Zephyr cycle
    /// - Parameters:
    ///   - testCaseKey: key of the Zephyr test case
    ///   - resultStatus: resultStatus name of the status to be set for the test case
    ///
    /// - seealso Scale.SystemTestCaseStatus.Cloud
    /// - seealso Squad.SystemTestCaseStatus.Cloud
    public static func setTestCaseStatus(testCaseKey: String, resultStatus: String) {
        TestCasesRegistry.getInstance().setCurrentTestTestCaseStatus(tcmType: TcmType.zephyr,
                                                                     testCaseId: testCaseKey,
                                                                     status: resultStatus)
    }
    
    /// Optional.
    /// Disables result upload. Same as #setTestCycleKey(String), this method must be invoked before all tests
    public static func disableSync() {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: syncEnabledKey, value: "false")
    }
    
    /// Optional.
    /// Enables real-time results upload. In this mode, result of test execution will be uploaded immediately after test finish. Same as #setTestCycleKey(String), this
    /// method must be invoked before all tests
    public static func enableRealTimeSync() {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: syncRealTimeKey, value: "true")
    }
    
    private static func noExecutedTests() -> Bool {
        let hasTests = RunContext.getInstance().hasTests()
        if (hasTests) {
            print("The Zephyr configuration must be provided before start of tests.\nHint: move the configuration to the code block which is executed before all tests")
        }
        return !hasTests
    }
}
