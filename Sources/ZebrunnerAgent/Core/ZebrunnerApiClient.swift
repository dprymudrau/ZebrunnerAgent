//
//  ZebrunnerApiClient.swift
//  
//
//  Created by Dzmitry Prymudrau on 20.07.22.
//

import Foundation
import XCTest

public class ZebrunnerApiClient {
    
    private static var instance: ZebrunnerApiClient?
    private var requestMgr: RequestManager!
    private var configuration: Configuration!
    
    private init(configuration: Configuration) {
        self.configuration = configuration
        self.requestMgr = RequestManager(baseUrl: configuration.baseUrl, refreshToken: configuration.accessToken)
        if let authToken = self.authenticate() {
            self.requestMgr.setAuthToken(authToken: authToken)
        }
    }
    
    public static func setUp(configuration: Configuration) -> ZebrunnerApiClient? {
        if (self.instance == nil) {
            self.instance = ZebrunnerApiClient(configuration: configuration)
        }
        return instance
    }
    
    public static func getInstance() throws -> ZebrunnerApiClient {
        guard let instance = ZebrunnerApiClient.instance else {
            throw ZebrunnerAgentError(description: "There was no instance of ZebrunnerApiClient created")
        }
        return instance
    }
    
    /// Send authentication request to get authToken for future requests
    /// - Returns String auth token
    private func authenticate() -> String? {
        let request = self.requestMgr.buildAuthRequest()
        let (data, _, error) = URLSession.shared.syncRequest(with: request)
        
        guard let data = data else {
            print("Failed to authenticate: \(String(describing: error?.localizedDescription))")
            return nil
        }
        guard let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) else {
            print("Failed to map response into AuthResponse from: \(data)")
            return nil
        }
        
        return authResponse.authToken
    }
    
    /// Creates a new test run on Zebrunner
    /// - Parameter testRunStartRequest: details to start test run
    public func startTestRun(testRunStartRequest: TestRunStartDTO) -> TestRunStartResponse? {
        let request = requestMgr.buildStartTestRunRequest(projectKey: configuration.projectKey,
                                                          testRunStartRequest: testRunStartRequest)
        let (data, _, error) = URLSession.shared.syncRequest(with: request)
        
        guard let data = data else {
            print("Failed to create Test Run: \(String(describing: error?.localizedDescription))")
            return nil
        }
        guard let testRunStartResponse = try? JSONDecoder().decode(TestRunStartResponse.self, from: data) else {
            print("Failed to map start test run response into TestRunStartResponse from: \(data)")
            return nil
        }
        return testRunStartResponse
    }
    
    
    /// Finishes existing test run on Zebrunner
    ///  - Parameters:
    ///   - testRunFinishRequest: details to finish test run
    public func finishTestRun(testRunFinishRequest: TestRunFinishDTO) {
        guard let id = getTestRunId() else {
            return
        }
        let request = requestMgr.buildFinishTestRunRequest(testRunId: id, testRunFinishRequest: testRunFinishRequest)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Starts test case execution in given test run on Zebrunner
    ///  - Parameters:
    ///     - testCaseStartRequest: details to start test case
    public func startTest(testCaseStartRequest: TestCaseStartDTO) -> TestCaseStartResponse? {
        guard let id = getTestRunId() else {
            return nil
        }
        let request = requestMgr.buildStartTestRequest(testRunId: id, testCaseStartRequest: testCaseStartRequest)
        let (data, _, error) = URLSession.shared.syncRequest(with: request)
        guard let data = data else {
            print("Failed to create test case execution: \(String(describing: error?.localizedDescription))")
            return nil
        }
        guard let testCaseStartResponse = try? JSONDecoder().decode(TestCaseStartResponse.self, from: data) else {
            print("Failed to map start test case response into TestCaseStartResponse from: \(data)")
            return nil
        }
        return testCaseStartResponse
    }
    
    /// Finishes test case on Zebrunner with the reason of the result
    ///  - Parameters:
    ///     - testCaseName: test case name
    ///     - testCaseFinishRequest: details to finish test case
    public func finishTest(testCaseName: String, testCaseFinishRequest: TestCaseFinishDTO) {
        guard let id = getTestRunId(),
              let testCaseId = getTestCaseId(testCaseName: testCaseName) else {
            return
        }
        let request = requestMgr.buildFinishTestRequest(testRunId: id,
                                                        testId: testCaseId,
                                                        testCaseFinishRequest: testCaseFinishRequest)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Updates test case data on Zebrunner
    ///  - Parameters:
    ///    - testCaseUpdateRequest: details to update test case
    public func updateTest(testCaseUpdateRequest: TestCaseUpdateDTO) {
        guard let id = getTestRunId(),
              let testCaseId = getTestCaseId(testCaseName: testCaseUpdateRequest.name) else {
            return
        }
        let request = requestMgr.buildUpdateTestRequest(testRunId: id, testId: testCaseId, testCaseUpdateRequest: testCaseUpdateRequest)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Sends bulk logs for given test case
    /// - Parameters:
    ///   - testCaseName: name of test case to send logs
    ///   - logMessages: log messages to send
    ///   - level: log level of log messages
    ///   - timestamp: timestamp for log messages
    public func sendLogs(testCaseName: String, logMessages: [String], level: LogLevel, timestamp: String) {
        guard let id = getTestRunId(),
              let testCaseId = getTestCaseId(testCaseName: testCaseName) else {
            return
        }
        let request = requestMgr.buildLogRequest(testRunId: id,
                                                 testId: testCaseId,
                                                 logMessages: logMessages,
                                                 level: level,
                                                 timestamp: timestamp)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Attaches a screenshot for given test case
    ///  - Parameters:
    ///     - testCaseName: name of test case to attach screenshot
    ///     - screenshot: png representation of screenshot
    public func sendScreenshot(_ testCaseName: String, screenshot: Data?) {
        guard let id = getTestRunId(),
              let testCaseId = getTestCaseId(testCaseName: testCaseName) else {
            return
        }
        let request = requestMgr.buildScreenshotRequest(testRunId: id,
                                                        testId: testCaseId,
                                                        screenshot: screenshot)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Attaches an artifact for given test case
    /// - Parameters:
    ///   - testCaseName: name of test case to attach artifact
    ///   - artifact: binary data of an artifact
    ///   - name: artifact name
    public func sendTestCaseArtifact(for testCaseName: String, with artifact: Data?, name: String) {
        guard let id = getTestRunId(),
              let testCaseId = getTestCaseId(testCaseName: testCaseName) else {
            return
        }
        guard let data = artifact else {
            print("There is no data to attach")
            return
        }
        let request = requestMgr.buildTestCaseArtifactsRequest(testRunId: id,
                                                               testCaseId: testCaseId,
                                                               artifact: data,
                                                               name: name)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Attaches an artifact to test run
    /// - Parameters:
    ///   - artifact: binary data of an artifact
    ///   - name: artifact name
    public func sendTestRunArtifact(artifact: Data?, name: String) {
        guard let id = getTestRunId() else {
            return
        }
        guard let data = artifact else {
            print("There is no data to attach")
            return
        }
        let request = requestMgr.buildTestRunArtifactsRequest(testRunId: id,
                                                              artifact: data,
                                                              name: name)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Attaches an artifact reference for given test case
    /// - Parameters:
    ///   - testCaseName: name of test case to attach artifact reference
    ///   - references: array with key-value pairs: name of the reference and its value
    public func sendTestCaseArtifactReference(testCaseName: String, references: [String: String]) {
        guard let id = getTestRunId(),
              let testCaseId = getTestCaseId(testCaseName: testCaseName) else {
            return
        }
        let request = requestMgr.buildTestCaseArtifactReferencesRequest(testRunId: id,
                                                                        testCaseId: testCaseId,
                                                                        references: references)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Attaches an artifact reference for test run
    /// - Parameters:
    ///   - references: array with key-value pairs: name of the reference and its value
    public func sendTestRunArtifactReferences(references: [String: String]) {
        guard let id = getTestRunId() else {
            return
        }
        let request = requestMgr.buildTestRunArtifactReferencesRequest(testRunId: id, references: references)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Attaches an array of labels to test run
    /// - Parameter labels: array with key-value pairs: name of the label and its value
    public func sendTestRunLabels(_ labels: [String: String]) {
        guard let id = getTestRunId() else {
            return
        }
        let request = requestMgr.buildTestRunLabelsRequest(testRunId: id, labels: labels)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Attaches an array of labels to given test case
    /// - Parameter testCaseName: test case name
    /// - Parameter labels: array with key-value pairs: name of the label and its value
    public func sendTestCaseLabels(for testCaseName: String, labels: [String: String]) {
        guard let id = getTestRunId(),
              let testCaseId = getTestCaseId(testCaseName: testCaseName) else {
            return
        }
        let request = requestMgr.buildTestCaseLabelsRequest(testRunId: id,
                                                            testCaseId: testCaseId,
                                                            labels: labels
        )
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Updates results for given test cases for given TCM
    /// - Parameters:
    ///   - testCaseId: test case id
    ///   - results: array of objects that contain information of TCM type, TCM test case ids and their results
    public func upsertTestCaseResults(for testCaseId: Int, results: [TcmTestCaseResultDTO]) {
        guard let id = getTestRunId() else {
            return
        }
        let request = requestMgr.buildTestCaseResultsRequest(testRunId: id,
                                                             testCaseId: testCaseId,
                                                             results: results)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    private func getTestRunId() -> Int? {
        guard let id = RunContext.getInstance().getTestRunId() else {
            print("There is no test run id found")
            return nil
        }
        return id
    }
    
    private func getTestCaseId(testCaseName: String) -> Int? {
        guard let testCaseId = RunContext.getInstance().getTestCaseId(testCaseName: testCaseName) else {
            print("There is no test case found \(testCaseName)")
            return nil
        }
        return testCaseId
    }
}

// Extension of URLSesssion to execute synchronous requests
extension URLSession {
    
    /// Performs synchronous network request.
    /// - Parameter request: URLRequest object
    /// - Returns: Data, URLResponse, Error
    fileprivate func syncRequest(with request: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let dispatchGroup = DispatchGroup()
        let task = dataTask(with: request) {
            data = $0
            response = $1
            error = $2
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        task.resume()
        dispatchGroup.wait()
        
        // Check if response status code out of 200s
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            print("Unexpected response code: \(httpResponse.statusCode) for request with url: \(String(describing: request.url))")
            if let data = data,
               let err = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Data: \(err)")
            }
        }
        
        return (data, response, error)
    }
}

extension Date {
    
    /// Returns Date in ISO8601 timestamp with an offset from UTC
    /// - Parameter format: date format
    /// - Returns: String date
    func toString(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ") -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
    
    /// Returns current epoch unix timestamp  with millisecond-precision
    /// - Returns: String timestamp
    func currentEpochUnixTimestamp() -> String {
        let timestamp = Int(Date().timeIntervalSince1970 * 1_000)
        return String(timestamp)
    }
}

