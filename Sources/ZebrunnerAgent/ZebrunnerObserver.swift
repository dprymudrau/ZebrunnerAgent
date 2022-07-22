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
        zebrunnerClient.startTestRun(testRunName: testBundle.className)
    }
    
    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        print(testSuite)
    }
    
    public func testCaseWillStart(_ testCase: XCTestCase) {
        print(testCase)
    }
    
    public func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
        print(issue)
    }
    
    public func testCase(_ testCase: XCTestCase, didRecord expectedFailure: XCTExpectedFailure) {
        print(expectedFailure)
    }
    
    public func testCaseDidFinish(_ testCase: XCTestCase) {
    }
    
    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
        zebrunnerClient.finishTestRun()
    }
    
}
