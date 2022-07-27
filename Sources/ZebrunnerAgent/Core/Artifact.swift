//
//  Artifact.swift
//  
//
//  Created by Dzmitry Prymudrau on 27.07.22.
//

import Foundation
import XCTest

public class Artifact {
    private init() {}
    
    public static func attachArtifactToTestCase(_ testCase: XCTestCase, artifact: Data?) {
        let testCaseName = testCase.name
        attachArtifactToTestCase(testCaseName, artifact: artifact)
    }
    
    public static func attachArtifactToTestCase(_ testCase: XCTestCase, artifact: [UInt8]) {
        let testCaseName = testCase.name
        let data = Data(artifact)
        attachArtifactToTestCase(testCaseName, artifact: data)
    }
    
    public static func attachArtifactToTestCase(_ testCase: String, artifact: [UInt8]) {
        let data = Data(artifact)
        attachArtifactToTestCase(testCase, artifact: data)
    }
    
    public static func attachArtifactToTestCase(_ testCase: String, artifact: Data?) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifact(for: testCase, with: artifact)
    }
    
    public static func attachArtifactReferenceToTestCase(_ testCase: XCTestCase, key: String, value: String) {
        let references = [[key: value]]
        let testCaseName = testCase.name
        attachArtifactReferencesToTestCase(testCaseName, references: references)
    }
    
    public static func attachArtifactReferenceToTestCase(_ testCase: XCTestCase, references: [[String: String]]) {
        let testCaseName = testCase.name
        attachArtifactReferencesToTestCase(testCaseName, references: references)
    }
    
    public static func attachArtifactReferenceToTestCase(_ testCase: String, key: String, value: String) {
        let references = [[key: value]]
        attachArtifactReferencesToTestCase(testCase, references: references)
    }
    
    public static func attachArtifactReferencesToTestCase(_ testCase: String, references: [[String: String]]) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifactReference(testCase: testCase, references: references)
    }
    
    public static func attachArtifactToTestRun(artifact: [UInt8]) {
        let data = Data(artifact)
        attachArtifactToTestRun(artifact: data)
    }
    
    public static func attachArtifactToTestRun(artifact: Data?) {
        try? ZebrunnerApiClient.getInstance().sendTestRunArtifact(artifact: artifact)
    }
    
    public static func attachArtifactReferenceToTestRun(key: String, value: String) {
        let references = [[key: value]]
        attachArtifactReferenceToTestRun(references: references)
    }
    
    public static func attachArtifactReferenceToTestRun(references: [[String: String]]) {
        try? ZebrunnerApiClient.getInstance().sendTestRunArtifactReferences(references: references)
    }
    
}