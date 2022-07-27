//
//  Label.swift
//  
//
//  Created by Dzmitry Prymudrau on 27.07.22.
//

import Foundation
import XCTest

public class Label {
    private init() {}
    
    public static func attachTestRunLabel(key: String, value: String) {
        let labels = [[key: value]]
        attachTestRunLabels(labels: labels)
    }
    
    public static func attachTestRunLabels(labels: [[String: String]]) {
        try? ZebrunnerApiClient.getInstance().sendTestRunLabels(labels)
    }
    
    public func attachTestCaseLabel(testCase: XCTestCase, key: String, value: String) {
        attachTestCaseLabel(testCase: testCase.name, key: key, value: value)
    }
    
    public func attachTestCaseLabel(testCase: String, key: String, value: String) {
        let labels = [[key: value]]
        attachTestCaseLabels(testCase: testCase, labels: labels)
    }
    
    public func attachTestCaseLabels(testCase: XCTestCase, labels: [[String: String]]) {
        attachTestCaseLabels(testCase: testCase.name, labels: labels)
    }
    
    public func attachTestCaseLabels(testCase: String, labels: [[String: String]]) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseLabels(for: testCase, labels: labels)
    }
    
}
