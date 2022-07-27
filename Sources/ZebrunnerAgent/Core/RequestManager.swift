//
//  RequestManager.swift
//  
//
//  Created by Dzmitry Prymudrau on 20.07.22.
//

import Foundation
import AppKit

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
        case multipart = "multipart/form-data ; boundary="
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
    
    public func buildTestCaseArtifactsRequest(testRunId: Int, testCaseId: Int, artifact: Data, name: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testCaseId)/artifacts")!
        return prepareMultipartRequest(url: url, artifact: artifact, name: name)
    }
    
    public func buildTestRunArtifactsRequest(testRunId: Int, artifact: Data, name: String) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/artifacts")!
        return prepareMultipartRequest(url: url, artifact: artifact, name: name)
    }
    
    public func buildTestCaseArtifactReferencesRequest(testRunId: Int, testCaseId: Int, references: [String: String]) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testCaseId)/artifact-references")!
        let body = getBodyForArtifacts(keyValues: references)
        return prepareRequest(url: url, method: HttpMethod.PUT, body: body)
    }
    
    public func buildTestRunArtifactReferencesRequest(testRunId: Int, references: [String: String]) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/artifact-references")!
        let body = getBodyForArtifacts(keyValues: references)
        return prepareRequest(url: url, method: HttpMethod.PUT, body: body)
    }
    
    public func buildTestRunLabelsRequest(testRunId: Int, labels: [String: String]) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/labels")!
        let body = getBodyForLabels(keyValues: labels)
        return prepareRequest(url: url, method: .PUT, body: body)
    }
    
    public func buildTestCaseLabelsRequest(testRunId: Int, testCaseId: Int, labels: [String: String]) -> URLRequest {
        let url = URL(string: baseUrl + "/api/reporting/v1/test-runs/\(testRunId)/tests/\(testCaseId)/labels")!
        let body = getBodyForLabels(keyValues: labels)
        return prepareRequest(url: url, method: .PUT, body: body)
    }
    
    private func getBodyForLabels(keyValues: [String: String]) -> AttachementLabelDTO {
        var labels = [LabelDTO]()
        for (key, value) in keyValues {
            labels.append(LabelDTO(key: key, value: value))
        }
        return AttachementLabelDTO(items: labels)
    }
    
    private func getBodyForArtifacts(keyValues: [String: String]) -> AttachementArtifactDTO {
        var artifacts = [ArtifactDTO]()
        for (name, value) in keyValues {
            artifacts.append(ArtifactDTO(name: name, value: value))
        }
        return AttachementArtifactDTO(items: artifacts)
    }
    
    private func prepareRequest(url: URL, method: HttpMethod, body: AttachementLabelDTO) -> URLRequest {
        let jsonBody = try? JSONEncoder().encode(body)
        return prepareRequest(url: url, method: method, body: jsonBody, contentType: .json)
    }
    
    private func prepareRequest(url: URL, method: HttpMethod, body: AttachementArtifactDTO) -> URLRequest {
        let jsonBody = try? JSONEncoder().encode(body)
        return prepareRequest(url: url, method: method, body: jsonBody, contentType: .json)
    }
    
    private func prepareRequest(url: URL, method: HttpMethod, body: [String: AnyHashable]) -> URLRequest {
        let jsonBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        return prepareRequest(url: url, method: method, body: jsonBody, contentType: .json)
    }
    
    private func prepareRequest(url: URL, method: HttpMethod, body: Data?, contentType: ContentType = .json) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: contentTypeHeaderName)
        if let token = authToken {
            request.setValue("Bearer " + token, forHTTPHeaderField: authorizationHeaderName)
        }
        request.httpBody = body
        return request
    }
    
    private func prepareMultipartRequest(url: URL, artifact: Data, name: String, method: HttpMethod = .POST) -> URLRequest {
        let parameters = [
            [
                "key": "file",
                "src": artifact,
                "type": "file"
            ]] as [[String : Any]]
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                if param["contentType"] != nil {
                    body += "\r\nContent-Type: \(param["contentType"] as! String)"
                }
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                    let paramSrc = param["src"] as! Data
                    var fileContent = ""
                    if let content = String(data: paramSrc, encoding: .utf8) {
                        fileContent = content
                    } else {
                        body += "; filename=\"\(name)\"\r\n"
                        + "Content-Type: \"content-type header\"\r\n\r\n\(paramSrc)\r\n"
                    }
                    body += "; filename=\"\(name)\"\r\n"
                    + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                }
            }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)
        
        var request = URLRequest(url: url)
        if let token = authToken {
            request.setValue("Bearer " + token, forHTTPHeaderField: authorizationHeaderName)
        }
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        request.httpBody = postData
        return request
    }
}
