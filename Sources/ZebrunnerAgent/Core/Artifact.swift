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
    
    public static func attachArtifactToTestCase(testCase: XCTestCase, artifact: Data?) {
        let testCaseName = testCase.name
        attachArtifactToTestCase(testCase: testCaseName, artifact: artifact)
    }
    
    public static func attachArtifactToTestCase(testCase: XCTestCase, artifact: [UInt8]) {
        let testCaseName = testCase.name
        let data = Data(artifact)
        attachArtifactToTestCase(testCase: testCaseName, artifact: data)
    }
    
    public static func attachArtifactToTestCase(testCase: String, artifact: [UInt8]) {
        let data = Data(artifact)
        attachArtifactToTestCase(testCase: testCase, artifact: data)
    }
    
    public static func attachArtifactToTestCase(testCase: String, artifact: Data?) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifact(for: testCase, with: artifact)
    }
    
    public static func attachArtifactReferenceToTestCase(testCase: XCTestCase, key: String, value: String) {
        let references = [[key: value]]
        let testCaseName = testCase.name
        attachArtifactReferencesToTestCase(testCase: testCaseName, references: references)
    }
    
    public static func attachArtifactReferenceToTestCase(testCase: XCTestCase, references: [[String: String]]) {
        let testCaseName = testCase.name
        attachArtifactReferencesToTestCase(testCase: testCaseName, references: references)
    }
    
    public static func attachArtifactReferenceToTestCase(testCase: String, key: String, value: String) {
        let references = [[key: value]]
        attachArtifactReferencesToTestCase(testCase: testCase, references: references)
    }
    
    public static func attachArtifactReferencesToTestCase(testCase: String, references: [[String: String]]) {
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
