//
//  ZebrunnerObserver.swift
//  
//
//  Created by Dzmitry Prymudrau on 22.07.22.
//

import Foundation
import XCTest

@available(iOS 10.0, *)
@available(macOS 10.12, *)
public class ZebrunnerObserver: NSObject, XCTestObservation {
    
    private var zebrunnerClient: ZebrunnerApiClient!
    private static var observer: ZebrunnerObserver!
    private var testSuiteDictionary: [String: [XCTest]] = [:]
    
    private init(baseUrl: String, projectKey: String, refreshToken: String) {
        super.init()
        self.zebrunnerClient = ZebrunnerApiClient.shared(baseUrl: baseUrl, projectKey: projectKey, refreshToken: refreshToken)
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    public static func setUp(baseUrl: String, projectKey: String, refreshToken: String) {
        if(observer == nil) {
            self.observer = ZebrunnerObserver(baseUrl: baseUrl, projectKey: projectKey, refreshToken: refreshToken)
        }
    }
    
    public func testBundleWillStart(_ testBundle: Bundle) {
        guard let testRunName = ProcessInfo.processInfo.environment["TEST_RUN_NAME"],
              !testRunName.isEmpty else {
            zebrunnerClient.startTestRun(testRunName: "Test Run", startTime: Date().toString())
            return
        }
        zebrunnerClient.startTestRun(testRunName: testRunName, startTime: Date().toString())
    }
    
    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        testSuiteDictionary[testSuite.name] = testSuite.tests
    }
    
    public func testCaseWillStart(_ testCase: XCTestCase) {
        let className = getTestSuiteName(for: testCase)
        
        let testData = TestData(name: testCase.name,
                                className: className,
                                methodName: testCase.name)
        zebrunnerClient.startTest(testData: testData, startTime: Date().toString())
    }
    
    public func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
        if let tc = testCase as? XCZebrunnerTestCase,
           !tc.methodMaintainer.isEmpty {
            let testData = TestData(name: tc.name,
                                    className: getTestSuiteName(for: tc),
                                    methodName: tc.name,
                                    maintainer: tc.methodMaintainer)
            zebrunnerClient.updateTest(testData: testData)
        }
        
        var failureDescription: String
        if let reason = issue.detailedDescription {
            failureDescription = reason
        } else {
            failureDescription = issue.compactDescription
        }
        if !failureDescription.isEmpty {
            zebrunnerClient.finishTest(result: "FAILED",
                                       reason: failureDescription,
                                       name: testCase.name,
                                       endTime: Date().toString())
        }
        zebrunnerClient.finishTest(result: "FAILED",
                                   name: testCase.name,
                                   endTime: Date().toString())
    }
    
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        if testCase.testRun!.hasSucceeded {
            if let tc = testCase as? XCZebrunnerTestCase,
               !tc.methodMaintainer.isEmpty {
                let testData = TestData(name: tc.name,
                                        className: getTestSuiteName(for: tc),
                                        methodName: tc.name,
                                        maintainer: tc.methodMaintainer)
                zebrunnerClient.updateTest(testData: testData)
            }
            zebrunnerClient.finishTest(result: "PASSED",
                                       name: testCase.name,
                                       endTime: Date().toString())
        }
    }
    
    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        testSuiteDictionary.removeValue(forKey: testSuite.name)
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
        zebrunnerClient.finishTestRun(endTime: Date().toString())
    }
    
    private func getTestSuiteName(for testCase: XCTestCase) -> String {
        for (suiteName, cases) in testSuiteDictionary {
            for test in cases {
                if test.name == testCase.name {
                    return suiteName
                }
            }
        }
        return "Unreconized"
    }
    
}

extension Date {
    func toString(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ") -> String{
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
}
