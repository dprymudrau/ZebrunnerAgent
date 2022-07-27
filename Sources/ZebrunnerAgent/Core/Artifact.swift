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
    
    //Artifacts to test case
    public static func attachToTestCase(_ testCase: String, artifact: [UInt8], name: String) {
        let data = Data(artifact)
        attachToTestCase(testCase, artifact: data, name: name)
    }
    
    public static func attachToTestCase(_ testCase: String, artifactPath: String, name: String) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifact(for: testCase,
                                                                   with: getFileData(pathToFile: artifactPath),
                                                                   name: name)
    }
    
    public static func attachToTestCase(_ testCase: String, artifact: Data, name: String) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifact(for: testCase, with: artifact, name: name)
    }
    
    //Artifact References to test case
    public static func attachReferenceToTestCase(_ testCase: String, key: String, value: String) {
        let references = [key: value]
        attachReferencesToTestCase(testCase, references: references)
    }
    
    public static func attachReferencesToTestCase(_ testCase: String, references: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifactReference(testCase: testCase, references: references)
    }
    
    //Artifact References to test run
    public static func attachToTestRun(artifact: [UInt8], name: String) {
        let data = Data(artifact)
        attachToTestRun(artifact: data, name: name)
    }
    
    public static func attachToTestRun(artifactPath: String, name: String) {
        try? ZebrunnerApiClient.getInstance().sendTestRunArtifact(artifact: getFileData(pathToFile: artifactPath),
                                                                  name: name)
    }
    
    public static func attachToTestRun(artifact: Data, name: String) {
        try? ZebrunnerApiClient.getInstance().sendTestRunArtifact(artifact: artifact, name: name)
    }
    
    //Artifacts to test run
    public static func attachReferenceToTestRun(key: String, value: String) {
        let references = [key: value]
        attachReferenceToTestRun(references: references)
    }
    
    public static func attachReferenceToTestRun(references: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestRunArtifactReferences(references: references)
    }
    
    private static func getFileData(pathToFile: String) -> Data? {
        return try? NSData(contentsOfFile:pathToFile, options:[]) as Data
    }
}
