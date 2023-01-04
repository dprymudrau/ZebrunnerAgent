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
    
    var testIdToTcmTypeToTestCaseIdToStatus: [Int: [TcmType : [String : String]]] = [:]
    
    private init() {}
    
    public static func getInstance() -> TestCasesRegistry {
        if (self.instance == nil) {
            self.instance = TestCasesRegistry()
        }
        return instance
    }
    
    func addTestCasesToCurrentTest(tcmType: TcmType, testCaseIds: [String]) {
        guard let testId = RunContext.getInstance().getCurrentTestCaseId(),
              let testName = RunContext.getInstance().getCurrentTestCaseName() else {
            return
        }
        guard let tcmTypeKey = tcmTypeKey[tcmType] else {
            print("No key label for provided TCM \(tcmType)")
            return
        }
        let testCaseIdToStatus = getTestCaseIdToStatus(testId: testId, tcmType: tcmType)
        let filtered = testCaseIds.filter { testCaseId in
            return testCaseIdToStatus == nil || testCaseIdToStatus![testCaseId] == nil
        }
        for testCaseId in filtered {
            Label.attachToTestCase(testName, key: tcmTypeKey, value: testCaseId)
            updateTestIdToTcmTypeToTestCaseIdToStatusMap(testId: testId, tcmType: tcmType, testCaseId: testCaseId)
        }
    }
    
    func setCurrentTestTestCaseStatus(tcmType: TcmType, testCaseId: String, status: String) {
        guard let testId = RunContext.getInstance().getCurrentTestCaseId() else {
            return
        }
        updateTestIdToTcmTypeToTestCaseIdToStatusMap(testId: testId, tcmType: tcmType, testCaseId: testCaseId, status: status)
        let requestData = TcmTestCaseResultDTO(tcmType: tcmType, testCaseId: testCaseId, resultStatus: status)
        try? ZebrunnerApiClient.getInstance().upsertTestCaseResults(for: testId, results: [requestData])
    }
    
    func setExplicitStatusesOnCurrentTest(testCaseStatus: String?) {
        guard let testId = RunContext.getInstance().getCurrentTestCaseId() else {
            return
        }
        if let status = testCaseStatus {
            setTestCaseStatuses(testId: testId, status: status)
        }
        testIdToTcmTypeToTestCaseIdToStatus.removeValue(forKey: testId)
    }
    
    private func getTestCaseIdToStatus(testId: Int, tcmType: TcmType) -> [String: String]? {
        if let tcmTypeToTestCaseIdToStatus = testIdToTcmTypeToTestCaseIdToStatus[testId] {
            if let testCaseIdToStatus = tcmTypeToTestCaseIdToStatus[tcmType] {
                return testCaseIdToStatus
            }
        }
        return nil
    }
    
    private func updateTestIdToTcmTypeToTestCaseIdToStatusMap(testId: Int, tcmType: TcmType,
                                                              testCaseId: String, status: String = "") {
        var tempTcmTypeToTestCaseIdToStatus: [TcmType : [String : String]] = [:]
        
        let testCaseIdToStatus = getTestCaseIdToStatus(testId: testId, tcmType: tcmType)
        if var tempTestCaseIdToStatus = testCaseIdToStatus {
            tempTestCaseIdToStatus.merge([testCaseId : status]){(_,new) in new}
            tempTcmTypeToTestCaseIdToStatus[tcmType] = tempTestCaseIdToStatus
        } else {
            tempTcmTypeToTestCaseIdToStatus[tcmType] = [testCaseId : status]
        }
        
        if var tcmTypeToTestCaseIdToStatus = testIdToTcmTypeToTestCaseIdToStatus[testId] {
            tcmTypeToTestCaseIdToStatus.merge(tempTcmTypeToTestCaseIdToStatus){(_,new) in new}
            testIdToTcmTypeToTestCaseIdToStatus[testId] = tcmTypeToTestCaseIdToStatus
        } else {
            testIdToTcmTypeToTestCaseIdToStatus[testId] = tempTcmTypeToTestCaseIdToStatus
        }
    }
    
    private func setTestCaseStatuses(testId: Int, status: String) {
        var results = [] as [TcmTestCaseResultDTO]
        if let tcmTypeToTestCaseIdToStatus = testIdToTcmTypeToTestCaseIdToStatus[testId] {
            for (tcmType, testCaseIdToStatus) in tcmTypeToTestCaseIdToStatus {
                for (testCaseId, explicitStatus) in testCaseIdToStatus {
                    if explicitStatus.isEmpty {
                        results.append(TcmTestCaseResultDTO(tcmType: tcmType,
                                                            testCaseId: testCaseId,
                                                            resultStatus: status))
                    }
                }
            }
        }
        if (!results.isEmpty) {
            try? ZebrunnerApiClient.getInstance().upsertTestCaseResults(for: testId, results: results)
        }
    }
    
}
