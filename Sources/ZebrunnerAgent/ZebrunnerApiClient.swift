//
//  File.swift
//  
//
//  Created by Dzmitry Prymudrau on 20.07.22.
//

import Foundation

@available(iOS 10.0, *)
@available(macOS 10.12, *)
public class ZebrunnerApiClient {
    private static var client: ZebrunnerApiClient!
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
        if(self.client == nil) {
            self.client = ZebrunnerApiClient(baseUrl: baseUrl, projectKey: projectKey, refreshToken: refreshToken)
        }
        return client
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
    ///     - projectKey: name of the project on Zebrunner
    ///     - testRunName: name of test run that will be show on Test Runs page
    public func startTestRun(testRunName: String) {
        let request = requestMgr.buildStartTestRunRequest(projectKey: self.projectKey, testRunName: testRunName)
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
    public func finishTestRun() {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildFinishTestRunRequest(testRunId: id)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Starts test case execution in given test run on Zebrunner
    ///  - Parameters:
    ///     - name: test case display name
    ///     - className: test case class/file name
    ///     - methodName: test case method name
    public func startTest(name: String, className: String, methodName: String) {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildStartTestRequest(testRunId: id, name: name, className: className, methodName: methodName)
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
    public func finishTest(result: String, reason: String, name: String) {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildFinishTestRequest(testRunId: id, testId: self.testCasesExecuted[name]!, result: result, reason: reason)
        _ = URLSession.shared.syncRequest(with: request)
    }
    
    /// Finishes test case on Zebrunner
    ///  - Parameters:
    ///     - result: result of test case execution can be PASSED, FAILED, ABORTED, SKIPPED
    ///     - name: name of test case that shuld be finished
    public func finishTest(result: String, name: String) {
        guard let id = testRunResponse?.id else {
            print("There is no test run id found \(String(describing: testRunResponse))")
            return
        }
        let request = requestMgr.buildFinishTestRequest(testRunId: id, testId: self.testCasesExecuted[name]!, result: result)
        _ = URLSession.shared.syncRequest(with: request)
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
            print("Unexpected response code: \(httpResponse.statusCode)")
            if let data = data,
               let err = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Data: \(err)")
            }
        }
        
        return (data, response, error)
    }
}



