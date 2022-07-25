//
//  File.swift
//  
//
//  Created by Dzmitry Prymudrau on 20.07.22.
//

import Foundation
import XCTest

public class ZebrunnerApiClient {
    public static var shared: ZebrunnerApiClient?
    private var requestMgr: RequestManager!
    private var projectKey = ""
    private var testRunResponse: TestRunResponse?
    private var testCasesExecuted: [String: Int] = [:]
    
    private init(baseUrl: String, projectKey: String, refreshToken: String) {
        self.projectKey = projectKey
        self.requestMgr = RequestManager(baseUrl: baseUrl, refreshToken: refreshToken)
        if let authToken = self.authenticate() {
            self.requestMgr.setAuthToken(authToken: authToken)
        }
    }
    
    public static func shared(baseUrl: String, projectKey: String, refreshToken: String) -> ZebrunnerApiClient? {
        if(self.shared == nil) {
            self.shared = ZebrunnerApiClient(baseUrl: baseUrl, projectKey: projectKey, refreshToken: refreshToken)
        }
        return shared
    }
    
    /// Send authentication request to get authToken for future requests
    /// - Returns String auth token
    private func authenticate() -> String? {
        let request = self.requestMgr.buildAuthRequest()
        let (data, _, error) = URLSession.shared.syncRequest(with: request)
        
        //Check if data exists and can be mapped
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
    
    /// Creates new test run on Zebrunner
    ///  - Parameters:
    ///     - testRunName: name of test run that will be show on Test Runs page
    ///     - startTime: ISO8601 timestamp with an offset from UTC of test run
    public func startTestRun(testRunName: String, startTime: String) {
        let request = requestMgr.buildStartTestRunRequest(projectKey: self.projectKey, testRunName: testRunName, startTime: startTime)
        let (data, _, error) = URLSession.shared.syncRequest(with: request)
        
        guard let data = data else {
            print("Failed to create Test Run: \(String(describing: error?.localizedDescription))")
            return
        }
        if let startTestRunResponse = try? JSONDecoder().decode(TestRunResponse.self, from: data) {
            self.testRunResponse = startTestRunResponse
        }
    }
    
    
    /// Finishes existing test run on Zebrunner
    ///  - Parameters:
    ///   - endTime: ISO8601 timestamp with an offset from UTC of test run finish
    public func finishTestRun(endTime: String) {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildFinishTestRunRequest(testRunId: id , endTime: endTime)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Starts test case execution in given test run on Zebrunner
    ///  - Parameters:
    ///     - testData: data about executed test contains test case name, class name, method maintainer
    ///     - startTime: ISO8601 timestamp with an offset from UTC of test execution start
    public func startTest(testData: TestData, startTime: String) {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildStartTestRequest(testRunId: id, testData: testData, startTime: startTime)
        let (data, _, error) = URLSession.shared.syncRequest(with: request)
        guard let data = data else {
            print("Failed to create test case execution: \(String(describing: error?.localizedDescription))")
            return
        }
        guard let startTestCaseResponse = try? JSONDecoder().decode(StartTestCaseResponse.self, from: data) else {
            print("Failed to map start test case response into StartTestCaseResponse from: \(data)")
            return
        }
        
        self.testCasesExecuted[startTestCaseResponse.name] = startTestCaseResponse.id
    }
    
    /// Finishes test case on Zebrunner with the reason of the result
    ///  - Parameters:
    ///     - result: result of test case execution can be PASSED, FAILED, ABORTED, SKIPPED
    ///     - reason: message somehow explaining the result
    ///     - name: name of test case that shuld be finished
    ///     - endTime: ISO8601 timestamp with an offset from UTC of test execution finish
    public func finishTest(result: String, reason: String, name: String, endTime: String) {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildFinishTestRequest(testRunId: id,
                                                        testId: self.testCasesExecuted[name]!,
                                                        result: result,
                                                        reason: reason,
                                                        endTime: endTime)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Finishes test case on Zebrunner
    ///  - Parameters:
    ///     - result: result of test case execution can be PASSED, FAILED, ABORTED, SKIPPED
    ///     - name: name of test case that shuld be finished
    ///     - endTime: ISO8601 timestamp with an offset from UTC of test execution finish
    public func finishTest(result: String, name: String, endTime: String) {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildFinishTestRequest(testRunId: id,
                                                        testId: self.testCasesExecuted[name]!,
                                                        result: result,
                                                        endTime: endTime)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Updates test case data
    ///  - Parameters:
    ///   - testData: data about executed test contains test case name, class name, method maintainer
    public func updateTest(testData: TestData) {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildUpdateTestRequest(testRunId: id, testId: self.testCasesExecuted[testData.name]!, testData: testData)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Attaches screenshot for given test case
    ///  - Parameters:
    ///     - testCase: object of executed test case
    ///     - screenshot: png representation of screenshot
    public func sendScreenshot(_ testCase: XCTestCase, screenshot: Data?) {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildScreenshotRequest(testRunId: id,
                                                        testId: self.testCasesExecuted[testCase.name]!,
                                                        screenshot: screenshot)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    public func sendLogs(logs: [[String: AnyHashable]]) {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildLogsRequest(testRunId: id, logs: logs)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    public func getTestCaseId(for testCaseName: String) -> Int {
        guard let id = self.testCasesExecuted[testCaseName] else {
            return 0
        }
        return id
    }
}

// Extension of URLSesssion to execute synchronous requests.
extension URLSession {
    
    ///Performs synchronous network request.
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



