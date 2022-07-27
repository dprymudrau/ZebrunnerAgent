//
//  RequestManager.swift
//  
//
//  Created by Dzmitry Prymudrau on 20.07.22.
//

import Foundation

class RequestManager {
    private var baseUrl: String!
    private var refreshToken: String!
    private var authToken: String?
    
    private let contentTypeHeaderName = "Content-Type"
    private let authorizationHeaderName = "Authorization"
    
    private enum HttpMethod: String {
        case POST = "POST"
        case PUT = "PUT"
    }
    
    private enum ContentType: String {
        case image = "image/png"
        case json = "application/json"
        case any = "*/*"
    }
    
    public init(baseUrl: String, refreshToken: String) {
        self.baseUrl = baseUrl
        self.refreshToken = refreshToken
    }
    
    public func setAuthToken(authToken: String) {
        self.authToken = authToken
    }
    
    public func buildAuthRequest() -> URLRequest {
        let url = URL(string: baseUrl + "/api/iam/v1/auth/refresh")!
        let body: [String: AnyHashable] = [
            "refreshToken": refreshToken
        ]
        return prepareRequest(url: url, method: .POST, body: body)
    }
    
    public func buildStartTestRunRequest(projectKey: String, testRunName: String, startTime: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs?projectKey=" + projectKey)!
        let body: [String: AnyHashable] = [
            "name": testRunName,
            "startedAt": startTime,
            "framework": "XCTest",
        ]
        return prepareRequest(url: url, method: .POST, body: body)
    }
    
    public func buildFinishTestRunRequest(testRunId: Int, endTime: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/" + String(testRunId))!
        let body: [String: AnyHashable] = [
            "endedAt": endTime
        ]
        return prepareRequest(url: url, method: .PUT, body: body)
    }
    
    public func buildStartTestRequest(testRunId: Int, testData: TestData, startTime: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests")!
        let body = [
            "name": testData.name,
            "className": testData.className,
            "methodName": testData.methodName,
            "startedAt": startTime,
            "maintainer": testData.maintainer,
        ]
        
        return prepareRequest(url: url, method: .POST, body: body)
    }
    
    public func buildFinishTestRequest(testRunId: Int, testId: Int, result: String, reason: String, endTime: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testId)")!
        let body: [String: AnyHashable] = [
            "result": result,
            "reason": reason,
            "endedAt": endTime
        ]
        return prepareRequest(url: url, method: .PUT, body: body)
    }
    
    public func buildFinishTestRequest(testRunId: Int, testId: Int, result: String, endTime: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testId)")!
        let body: [String: AnyHashable] = [
            "result": result,
            "endedAt": endTime
        ]
        return prepareRequest(url: url, method: .PUT, body: body)
    }
    
    public func buildUpdateTestRequest(testRunId: Int, testId: Int, testData: TestData) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testId)?headless=true")!
        let body = [
            "name": testData.name,
            "className": testData.className,
            "methodName": testData.methodName,
            "maintainer": testData.maintainer,
        ]
        return prepareRequest(url: url, method: .PUT, body: body)
    }
    
    public func buildScreenshotRequest(testRunId: Int, testId: Int, screenshot: Data?) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testId)/screenshots")!
        return prepareRequest(url: url, method: .POST, body: screenshot!, contentType: .image)
    }
    
    public func buildTestCaseArtifactsRequest(testRunId: Int, testCaseId: Int, artifact: Data?) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testCaseId)/artifacts")!
        return prepareRequest(url: url, method: .POST, body: artifact, contentType: .any)
    }
    
    public func buildTestRunArtifactsRequest(testRunId: Int, artifact: Data?) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/artifacts")!
        return prepareRequest(url: url, method: HttpMethod.POST, body: artifact, contentType: .any)
    }
    
    public func buildTestCaseArtifactReferencesRequest(testRunId: Int, testCaseId: Int, references: [[String: String]]) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testCaseId)/artifact-references")!
        let body = [
            "items" : references
        ]
        return prepareRequest(url: url, method: HttpMethod.PUT, body: body)
    }
    
    public func buildTestRunArtifactReferencesRequest(testRunId: Int, references: [[String: String]]) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/artifact-references")!
        let body = [
            "items" : references
        ]
        return prepareRequest(url: url, method: HttpMethod.PUT, body: body)
    }
    
    public func buildTestRunLabelsRequest(testRunId: Int, labels: [[String: String]]) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/labels")!
        let body = [
            "items": labels
        ]
        return prepareRequest(url: url, method: .PUT, body: body)
    }
    
    public func buildTestCaseLabelsRequest(testRunId: Int, testCaseId: Int, labels: [[String: String]]) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testCaseId)/labels")!
        let body = [
            "items": labels
        ]
        return prepareRequest(url: url, method: .PUT, body: body)
    }
    
    private func prepareRequest(url: URL, method: HttpMethod, body: Any?, contentType: ContentType = .json) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: contentTypeHeaderName)
        if let token = authToken {
            request.setValue("Bearer " + token, forHTTPHeaderField: authorizationHeaderName)
        }
        
        switch contentType {
        case .json:
            request.httpBody = try? JSONSerialization.data(withJSONObject: body as! [String: String], options: .prettyPrinted)
        case .image:
            request.httpBody = body as! Data?
        case .any:
            request.httpBody = body as! Data?
        }
        
        return request
    }
}
