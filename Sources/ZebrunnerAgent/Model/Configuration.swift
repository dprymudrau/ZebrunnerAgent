//
//  Configuration.swift
//  
//
//  Created by asukhodolova on 8.11.22.
//

import Foundation

public struct Configuration {
    var isReportingEnabled: Bool
    var baseUrl: String
    var accessToken: String
    var projectKey: String
    var launchMode: LaunchMode = .default
    
    /// <#Description#>
    /// - Parameters:
    ///   - isReportingEnabled: whether reporting to Zebrunner is enabled
    ///   - baseUrl: Zebrunner tenant base url
    ///   - accessToken: needed for exchanging for a short living access token to perform future manipulations
    ///   - projectKey: the project this test run belongs to
    public init(isReportingEnabled: Bool = true, baseUrl: String, accessToken: String, projectKey: String, launchMode: LaunchMode = .default) {
        self.isReportingEnabled = isReportingEnabled
        self.baseUrl = baseUrl
        self.accessToken = accessToken
        self.projectKey = projectKey
        self.launchMode = launchMode
    }
}

public enum LaunchMode: String {
  case `default` = "DEFAULT"
  case debug = "DEBUG"
}
