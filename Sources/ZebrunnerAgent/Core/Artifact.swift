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
    
    public static func attachArtifactToTestCase(_ testCase: XCTestCase, artifact: Data, name: String) {
        let testCaseName = testCase.name
        attachArtifactToTestCase(testCaseName, artifact: artifact, name: name)
    }
    
    public static func attachArtifactToTestCase(_ testCase: XCTestCase, artifact: [UInt8], name: String) {
        let testCaseName = testCase.name
        let data = Data(artifact)
        attachArtifactToTestCase(testCaseName, artifact: data, name: name)
    }
    
    public static func attachArtifactToTestCase(_ testCase: String, artifact: [UInt8], name: String) {
        let data = Data(artifact)
        attachArtifactToTestCase(testCase, artifact: data, name: name)
    }
    
    public static func attachArtifactToTestCase(_ testCase: String, artifact: Data, name: String) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifact(for: testCase, with: artifact, name: name)
    }
    
    public static func attachArtifactReferenceToTestCase(_ testCase: XCTestCase, key: String, value: String) {
        let references = [key: value]
        let testCaseName = testCase.name
        attachArtifactReferencesToTestCase(testCaseName, references: references)
    }
    
    public static func attachArtifactReferencesToTestCase(_ testCase: XCTestCase, references: [String: String]) {
        let testCaseName = testCase.name
        attachArtifactReferencesToTestCase(testCaseName, references: references)
    }
    
    public static func attachArtifactReferenceToTestCase(_ testCase: String, key: String, value: String) {
        let references = [key: value]
        attachArtifactReferencesToTestCase(testCase, references: references)
    }
    
    public static func attachArtifactReferencesToTestCase(_ testCase: String, references: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifactReference(testCase: testCase, references: references)
    }
    
    public static func attachArtifactToTestRun(artifact: [UInt8], name: String) {
        let data = Data(artifact)
        attachArtifactToTestRun(artifact: data, name: name)
    }
    
    public static func attachArtifactToTestRun(artifact: Data, name: String) {
        try? ZebrunnerApiClient.getInstance().sendTestRunArtifact(artifact: artifact, name: name)
    }
    
    public static func attachArtifactReferenceToTestRun(key: String, value: String) {
        let references = [key: value]
        attachArtifactReferenceToTestRun(references: references)
    }
    
    public static func attachArtifactReferenceToTestRun(references: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestRunArtifactReferences(references: references)
    }
    
}
