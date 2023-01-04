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
    var projectKey: String = "DEF"
    var displayName: String = "Default Suite"
    var config: Config?
    var locale: String?
    var milestone: Milestone?
    var notifications: Notifications?
    var isDebugLogsEnabled: Bool = false
    var skipsAsFailures: Bool = true
    var testCaseStatusOnPass: String?
    var testCaseStatusOnFail: String?
    var testCaseStatusOnSkip: String?
    
    public init(isReportingEnabled: Bool) {
        self.isReportingEnabled = isReportingEnabled
        self.baseUrl = ""
        self.accessToken = ""
    }
    
    public init(isReportingEnabled: Bool, baseUrl: String, accessToken: String) {
        self.isReportingEnabled = isReportingEnabled
        self.baseUrl = baseUrl
        self.accessToken = accessToken
    }
}
