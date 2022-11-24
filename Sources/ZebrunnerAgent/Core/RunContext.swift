//
//  RunContext.swift
//  
//
//  Created by asukhodolova on 18.11.22.
//

import Foundation

class RunContext {
    
    private static var instance: RunContext!
    private var testRunId: Int?
    private var testCaseId: Int?
    private var testCasesExecuted: [String: Int] = [:]
    
    private init() {}
    
    public static func getInstance() -> RunContext {
        if (self.instance == nil) {
            self.instance = RunContext()
        }
        return instance
    }
    
    func setTestRunId(testRunId: Int) {
        self.testRunId = testRunId
    }
    
    func getTestRunId() -> Int? {
        return self.testRunId
    }
    
    func finishTestRun() {
        self.testRunId = nil
    }
    
    func addTestCase(testCaseName: String, testCaseId: Int) {
        self.testCasesExecuted[testCaseName] = testCaseId
        self.testCaseId = testCaseId
    }
    
    func getCurrentTestCaseId() -> Int? {
        return self.testCaseId
    }
    
    func getCurrentTestCaseName() -> String? {
        guard let id = testCaseId else {
            return nil
        }
        return self.testCasesExecuted.first(where: { $0.value == id })?.key
    }
    
    func getTestCaseId(testCaseName: String) -> Int? {
        return self.testCasesExecuted[testCaseName]
    }
    
    func finishTestCase() {
        self.testCaseId = nil
    }
    
    func hasTests() -> Bool {
        return !self.testCasesExecuted.isEmpty
    }
}
