//
//  Xray.swift
//  
//
//  Created by asukhodolova on 18.11.22.
//

import Foundation

public class Xray {
    
    public class SystemTestStatus {
        public enum Cloud {
            public static let passed = "PASSED"
            public static let executing = "EXECUTING"
            public static let notExecuted = "NOT_EXECUTED"
            public static let failed = "FAILED"
        }
        
        public enum Server {
            public static let pass = "PASS"
            public static let fail = "FAIL"
        }
    }
    
    static let syncEnabledKey = "com.zebrunner.app/tcm.xray.sync.enabled"
    static let syncRealTimeKey = "com.zebrunner.app/tcm.xray.sync.real-time"
    static let executionKey = "com.zebrunner.app/tcm.xray.test-execution-key"
    
    private init() {}
    
    /// Mandatory.
    /// The method sets Xray execution key. This method must be invoked before all tests
    /// - Parameter key: Xray execution key
    public static func setExecutionKey(key: String) {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: executionKey, value: key)
    }
    
    /// Mandatory.
    /// Using this mechanism you can set test keys associated with specific automated test
    /// - Parameter testKey: Xray test key
    public static func setTestKey(testKey: String) {
        TestCasesRegistry.getInstance().addTestCasesToCurrentTest(tcmType: TcmType.xray, testCaseIds: [testKey])
    }
    
    /// Sets the given status for the given test in Xray execution
    /// - Parameters:
    ///   - testKey: key of the Xray test
    ///   - resultStatus: name of the status to be set for the test
    ///
    /// - seealso Xray.SystemTestStatus.Cloud
    /// - seealso Xray.SystemTestStatus.Server
    public static func setTestStatus(testKey: String, resultStatus: String) {
        TestCasesRegistry.getInstance().setCurrentTestTestCaseStatus(tcmType: TcmType.xray,
                                                                     testCaseId: testKey,
                                                                     status: resultStatus)
    }
    
    /// Optional.
    /// Disables result upload. Same as #setExecutionKey(String), this method must be invoked before all tests
    public static func disableSync() {
        guard noExecutedTests() else {
            return
        }
        Label.attachToTestRun(key: syncEnabledKey, value: "false")
    }
    
    /// Optional.
    /// Enables real-time results upload. In this mode, result of test execution will be uploaded immediately after test finish. Same as #setExecutionKey(String), this
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
            print("The Xray configuration must be provided before start of tests.\nHint: move the configuration to the code block which is executed before all tests")
        }
        return !hasTests
    }
}
