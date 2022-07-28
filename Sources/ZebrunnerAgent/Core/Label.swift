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
    
    public static func attachToTestRun(key: String, value: String) {
        let labels = [key: value]
        attachTestRunLabels(labels: labels)
    }
    
    public static func attachToTestCase(labels: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestRunLabels(labels)
    }
        
    public static func attachToTestCase(_ testCase: String, key: String, value: String) {
        let labels = [key: value]
        attachTestCaseLabels(testCase, labels: labels)
    }
    
    public static func attachToTestCase(_ testCase: String, labels: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseLabels(for: testCase, labels: labels)
    }
    
}
