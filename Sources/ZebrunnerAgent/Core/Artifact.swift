//
//  Artifact.swift
//  
//
//  Created by Dzmitry Prymudrau on 27.07.22.
//

import Foundation

public class Artifact {
    private init() {}
    
    /// Attaches an artifact to test case
    /// - Parameters:
    ///   - testCase: test case name
    ///   - artifactPath: path to the artifact file
    ///   - name: filename
    public static func attachToTestCase(_ testCase: String, artifactPath: String, name: String) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifact(for: testCase,
                                                                   with: getFileData(pathToFile: artifactPath),
                                                                   name: name)
    }
    
    /// Attaches an artifact to test case
    /// - Parameters:
    ///   - testCase: test case name
    ///   - artifact: artifact binary data
    ///   - name: filename
    public static func attachToTestCase(_ testCase: String, artifact: Data, name: String) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifact(for: testCase, with: artifact, name: name)
    }
    
    /// Attaches an artifact reference to test case
    /// - Parameters:
    ///   - testCase: test case name
    ///   - key: name of the reference
    ///   - value: its value
    public static func attachReferenceToTestCase(_ testCase: String, key: String, value: String) {
        let references = [key: value]
        attachReferencesToTestCase(testCase, references: references)
    }
    
    /// Attaches an artifact reference to test case
    /// - Parameters:
    ///   - testCase: test case name
    ///   - references: array with key-value pairs: name of the reference and its value
    public static func attachReferencesToTestCase(_ testCase: String, references: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestCaseArtifactReference(testCaseName: testCase, references: references)
    }
    
    /// Attaches an artifact to test run
    /// - Parameters:
    ///   - artifactPath: path to the artifact file
    ///   - name: filename
    public static func attachToTestRun(artifactPath: String, name: String) {
        try? ZebrunnerApiClient.getInstance().sendTestRunArtifact(artifact: getFileData(pathToFile: artifactPath),
                                                                  name: name)
    }
    
    /// Attaches an artifact to test run
    /// - Parameters:
    ///   - artifact: artifact binary data
    ///   - name: filename
    public static func attachToTestRun(artifact: Data, name: String) {
        try? ZebrunnerApiClient.getInstance().sendTestRunArtifact(artifact: artifact, name: name)
    }
    
    /// Attaches an artifact reference to test run
    /// - Parameters:
    ///   - key: name of the reference
    ///   - value: its value
    public static func attachReferenceToTestRun(key: String, value: String) {
        let references = [key: value]
        attachReferenceToTestRun(references: references)
    }
    
    /// Attaches an artifact reference to test run
    /// - Parameters:
    ///   - references: array with key-value pairs: name of the reference and its value
    public static func attachReferenceToTestRun(references: [String: String]) {
        try? ZebrunnerApiClient.getInstance().sendTestRunArtifactReferences(references: references)
    }
    
    private static func getFileData(pathToFile: String) -> Data? {
        return try? NSData(contentsOfFile:pathToFile, options:[]) as Data
    }
}
