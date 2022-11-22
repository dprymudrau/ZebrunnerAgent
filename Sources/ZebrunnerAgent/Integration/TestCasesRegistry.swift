//
//  TestCasesRegistry.swift
//  
//
//  Created by asukhodolova on 18.11.22.
//

import Foundation

class TestCasesRegistry {
    
    private static var instance: TestCasesRegistry!
    
    let tcmTypeKey = [TcmType.testRail: "com.zebrunner.app/tcm.testrail.case-id",
                      TcmType.xray: "com.zebrunner.app/tcm.xray.test-key",
                      TcmType.zephyr: "com.zebrunner.app/tcm.zephyr.test-case-key"
    ] as [TcmType: String]
    
    private init() {}
    
    public static func getInstance() -> TestCasesRegistry {
        if (self.instance == nil) {
            self.instance = TestCasesRegistry()
        }
        return instance
    }
    
    func addTestCasesToCurrentTest(tcmType: TcmType, testCaseIds: [String]) {
        guard let testName = RunContext.getInstance().getCurrentTestCaseName() else {
            return
        }
        guard let tcmTypeKey = tcmTypeKey[tcmType] else {
            print("No key label for provided TCM \(tcmType)")
            return
        }
        for testCaseId in testCaseIds {
            Label.attachToTestCase(testName, key: tcmTypeKey, value: testCaseId)
        }
    }
    
    func setCurrentTestTestCaseStatus(tcmType: TcmType, testCaseId: String, status: String) {
        guard let testName = RunContext.getInstance().getCurrentTestCaseName() else {
            return
        }
        let requestData = TcmTestCaseResultDTO(tcmType: tcmType, testCaseId: testCaseId, resultStatus: status)
        try? ZebrunnerApiClient.getInstance().updateTestCaseResults(for: testName, results: [requestData])
    }
}
