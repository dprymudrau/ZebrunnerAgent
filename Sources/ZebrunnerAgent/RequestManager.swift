//
//  RequestManager.swift
//  
//
//  Created by Dzmitry Prymudrau on 20.07.22.
//

import Foundation

@available(iOS 10.0, *)
@available(macOS 10.12, *)
class RequestManager {
    private var baseUrl: String!
    private var refreshToken: String!
    private var authToken: String?
    
    private let contentTypeHeaderName = "Content-Type"
    private let jsonHeadrValue = "application/json"
    private let authorizationHeaderName = "Authorization"
    
    public init(baseUrl: String, refreshToken: String) {
        self.baseUrl = baseUrl
        self.refreshToken = refreshToken
    }
    
    public func setAuthToken(authToken: String) {
        self.authToken = authToken
    }
    
    
    public func buildAuthRequest() -> URLRequest {
        let url = URL(string: baseUrl + "/api/iam/v1/auth/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(jsonHeadrValue, forHTTPHeaderField: contentTypeHeaderName)
        let body: [String: AnyHashable] = [
            "refreshToken": refreshToken
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        return request
    }
    
    public func buildStartTestRunRequest(projectKey: String, testRunName: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs?projectKey=" + projectKey)!
        var request = URLRequest(url: url)
        request.setValue(jsonHeadrValue, forHTTPHeaderField: contentTypeHeaderName)
        if let token = authToken {
            request.setValue("Bearer " + token, forHTTPHeaderField: authorizationHeaderName)
        }
        request.httpMethod = "POST"
        print("started at \(ISO8601DateFormatter().string(from: Date()))")
        let body: [String: AnyHashable] = [
            "name": testRunName,
            "startedAt": ISO8601DateFormatter().string(from: Date()),
            "framework": "XCTest",
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        return request
    }
    
    public func buildFinishTestRunRequest(testRunId: Int) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/" + String(testRunId))!
        var request = URLRequest(url: url)
        request.setValue(jsonHeadrValue, forHTTPHeaderField: contentTypeHeaderName)
        if let token = authToken {
            request.setValue("Bearer " + token, forHTTPHeaderField: authorizationHeaderName)
        }
        request.httpMethod = "PUT"
        let body: [String: AnyHashable] = [
            "endedAt": ISO8601DateFormatter().string(from: Date())
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        return request
    }
    
    public func buildStartTestRequest(testRunId: Int, name: String, className: String, methodName: String, maintainer: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(jsonHeadrValue, forHTTPHeaderField: contentTypeHeaderName)
        if let token = authToken {
            request.setValue("Bearer " + token, forHTTPHeaderField: authorizationHeaderName)
        }
        let body = [
            "name": name,
            "className": className,
            "methodName": methodName,
            "startedAt": ISO8601DateFormatter().string(from: Date()),
            "maintainer": maintainer,
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        return request
    }
    
    public func buildFinishTestRequest(testRunId: Int, testId: Int, result: String, reason: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(jsonHeadrValue, forHTTPHeaderField: contentTypeHeaderName)
        if let token = authToken {
            request.setValue("Bearer " + token, forHTTPHeaderField: authorizationHeaderName)
        }
        let body: [String: AnyHashable] = [
            "result": result,
            "reason": reason,
            "endedAt": ISO8601DateFormatter().string(from: Date())
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        return request
    }
    
    public func buildFinishTestRequest(testRunId: Int, testId: Int, result: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(jsonHeadrValue, forHTTPHeaderField: contentTypeHeaderName)
        if let token = authToken {
            request.setValue("Bearer " + token, forHTTPHeaderField: authorizationHeaderName)
        }
        let body: [String: AnyHashable] = [
            "result": result,
            "endedAt": ISO8601DateFormatter().string(from: Date())
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        return request
    }
}
