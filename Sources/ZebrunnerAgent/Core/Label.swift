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
        let labels = [key: value]
        attachTestRunLabels(labels: labels)
    }
    
    public static func attachTestRunLabels(labels: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestRunLabels(labels)
    }
    
    public static func attachTestCaseLabel(_ testCase: XCTestCase, key: String, value: String) {
        attachTestCaseLabel(testCase.name, key: key, value: value)
    }
    
    public static func attachTestCaseLabel(_ testCase: String, key: String, value: String) {
        let labels = [key: value]
        attachTestCaseLabels(testCase, labels: labels)
    }
    
    public static func attachTestCaseLabels(_ testCase: XCTestCase, labels: [String: String]) {
        attachTestCaseLabels(testCase.name, labels: labels)
    }
    
    public static func attachTestCaseLabels(_ testCase: String, labels: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseLabels(for: testCase, labels: labels)
    }
    
}
