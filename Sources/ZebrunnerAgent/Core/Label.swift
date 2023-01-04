//
//  Label.swift
//  
//
//  Created by Dzmitry Prymudrau on 27.07.22.
//

import Foundation

public class Label {
    private init() {}
    
    /// Attaches a label to test run
    /// - Parameters:
    ///   - key: name of the label
    ///   - value: its value
    public static func attachToTestRun(key: String, value: String) {
        let labels = [key: value]
        attachToTestRun(labels: labels)
    }
    
    /// Attaches an array of labels to test run
    /// - Parameter labels: array with key-value pairs: name of the label and its value
    public static func attachToTestRun(labels: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestRunLabels(labels)
    }
    
    /// Attaches a label to test case
    /// - Parameters:
    ///   - testCase: test case name
    ///   - key: name of the label
    ///   - value: its value
    public static func attachToTestCase(_ testCase: String, key: String, value: String) {
        let labels = [key: value]
        attachToTestCase(testCase, labels: labels)
    }
    
    /// Attaches an array of labels to test case
    /// - Parameters:
    ///   - testCase: test case name
    ///   - labels: array with key-value pairs: name of the label and its value
    public static func attachToTestCase(_ testCase: String, labels: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseLabels(for: testCase, labels: labels)
    }
    
}
