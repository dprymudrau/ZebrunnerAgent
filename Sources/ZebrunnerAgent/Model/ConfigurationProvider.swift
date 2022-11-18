//
//  ConfigurationProvider.swift
//  
//
//  Created by asukhodolova on 8.11.22.
//

import Foundation

protocol ConfigurationProtocol {
    func getConfiguration() throws -> Configuration?
}

class EnvironmentConfigurationProvider: ConfigurationProtocol {
    
    enum EnvironmentVariable {
        static let reportingEnabled = "REPORTING_ENABLED"
        static let serverHostname = "REPORTING_SERVER_HOSTNAME"
        static let serverAccessToken = "REPORTING_SERVER_ACCESS_TOKEN"
        static let projectKey = "REPORTING_PROJECT_KEY"
        static let runDisplayName = "REPORTING_RUN_DISPLAY_NAME"
        static let runBuild = "REPORTING_RUN_BUILD"
        static let runEnvironment = "REPORTING_RUN_ENVIRONMENT"
        static let runLocale = "REPORTING_RUN_LOCALE"
        
        static let runTreatSkipsAsFailures = "REPORTING_RUN_TREAT_SKIPS_AS_FAILURES"
        //static let runTestCaseStatusOnPass = "REPORTING_RUN_TEST_CASE_STATUS_ON_PASS"
        //static let runTestCaseStatusOnFail = "REPORTING_RUN_TEST_CASE_STATUS_ON_FAIL"
        //static let runTestCaseStatusOnSkip = "REPORTING_RUN_TEST_CASE_STATUS_ON_SKIP"
        
        static let notificationNotifyOnEachFailure = "REPORTING_NOTIFICATION_NOTIFY_ON_EACH_FAILURE"
        static let notificationSlackChannels = "REPORTING_NOTIFICATION_SLACK_CHANNELS"
        static let notificationMSTeamsChannels = "REPORTING_NOTIFICATION_MS_TEAMS_CHANNELS"
        static let notificationEmails = "REPORTING_NOTIFICATION_EMAILS"
        static let milestoneId = "REPORTING_MILESTONE_ID"
        static let milestoneName = "REPORTING_MILESTONE_NAME"
        static let debugLogsEnabled = "REPORTING_DEBUG_LOGS_ENABLED"
    }
    
    private func getEnvironmentVariable(_ name: String) -> String? {
        return ProcessInfo.processInfo.environment[name]
    }
    
    func getConfiguration() throws -> Configuration? {
        guard let isReportingEnabled = getEnvironmentVariable(EnvironmentVariable.reportingEnabled) else {
            return nil
        }
        guard isReportingEnabled == "true" else {
            return Configuration(isReportingEnabled: false)
        }
        guard let baseUrl = getEnvironmentVariable(EnvironmentVariable.serverHostname) else {
            throw ZebrunnerAgentError(description: "\(EnvironmentVariable.reportingEnabled) property is TRUE, but mandatory \(EnvironmentVariable.serverHostname) parameter is not defined")
        }
        guard let accessToken = getEnvironmentVariable(EnvironmentVariable.serverAccessToken) else {
            throw ZebrunnerAgentError(description: "\(EnvironmentVariable.reportingEnabled) property is TRUE, but mandatory \(EnvironmentVariable.serverAccessToken) parameter is not defined")
        }
        var configuration = Configuration(isReportingEnabled: isReportingEnabled == "true",
                                          baseUrl: baseUrl,
                                          accessToken: accessToken)
        if let projectKey = getEnvironmentVariable(EnvironmentVariable.projectKey) {
            configuration.projectKey = projectKey
        }
        if let displayName = getEnvironmentVariable(EnvironmentVariable.runDisplayName) {
            configuration.displayName = displayName
        }
        if let config = buildConfig() {
            configuration.config = config
        }
        if let locale = getEnvironmentVariable(EnvironmentVariable.runLocale) {
            configuration.locale = locale
        }
        if let skipsAsFailures = getEnvironmentVariable(EnvironmentVariable.runTreatSkipsAsFailures) {
            configuration.skipsAsFailures = (skipsAsFailures == "true")
        }
        if let milestone = buildMilestone() {
            configuration.milestone = milestone
        }
        if let notifications = buildNotifications() {
            configuration.notifications = notifications
        }
        if let isDebugLogsEnabled = getEnvironmentVariable(EnvironmentVariable.debugLogsEnabled) {
            configuration.isDebugLogsEnabled = (isDebugLogsEnabled == "true")
        }
        return configuration
    }
    
    private func buildConfig() -> Config? {
        var config = Config()
        if let build = getEnvironmentVariable(EnvironmentVariable.runBuild) {
            config.build = build
        }
        if let environment = getEnvironmentVariable(EnvironmentVariable.runEnvironment) {
            config.environment = environment
        }
        return config.isInitialized() ? config : nil
    }
    
    private func buildMilestone() -> Milestone? {
        var milestone = Milestone()
        if let milestoneId = getEnvironmentVariable(EnvironmentVariable.milestoneId) {
            milestone.id = Int(milestoneId)
        }
        if let milestoneName = getEnvironmentVariable(EnvironmentVariable.milestoneName) {
            milestone.name = milestoneName
        }
        return milestone.isInitialized() ? milestone : nil
    }
    
    private func buildNotifications() -> Notifications? {
        var notifications = Notifications()
        notifications.targets = []
        if let notifyOnEachFailure = getEnvironmentVariable(EnvironmentVariable.notificationNotifyOnEachFailure) {
            notifications.notifyOnEachFailure = Bool(notifyOnEachFailure)
        }
        if let slackChannels = getEnvironmentVariable(EnvironmentVariable.notificationSlackChannels) {
            notifications.targets?.append(Target(type: .slack, value: slackChannels))
        }
        if let msTeamsChannels = getEnvironmentVariable(EnvironmentVariable.notificationMSTeamsChannels) {
            notifications.targets?.append(Target(type: .msTeams, value: msTeamsChannels))
        }
        if let emails = getEnvironmentVariable(EnvironmentVariable.notificationEmails) {
            notifications.targets?.append(Target(type: .email, value: emails))
        }
        return notifications.isInitialized() ? notifications : nil
    }
}

class PropertiesConfigurationProvider: ConfigurationProtocol {
    
    private var testBundle: Bundle
    
    init(testBundle: Bundle) {
        self.testBundle = testBundle
    }
    
    enum Property {
        static let reportingEnabled = "ReportingEnabled"
        static let serverHostname = "ReportingServerHostname"
        static let serverAccessToken = "ReportingServerAccessToken"
        static let projectKey = "ReportingProjectKey"
        static let runDisplayName = "ReportingRunDisplayName"
        static let runBuild = "ReportingRunBuild"
        static let runEnvironment = "ReportingRunEnvironment"
        static let runLocale = "ReportingRunLocale"
        
        static let runTreatSkipsAsFailures = "ReportingRunTreatSkipsAsFailures"
        //static let runTestCaseStatusOnPass = "ReportingRunTestCaseStatusOnPass"
        //static let runTestCaseStatusOnFail = "ReportingRunTestCaseStatusOnFail"
        //static let runTestCaseStatusOnSkip = "ReportingRunTestCaseStatusOnSkip"
        
        static let notificationNotifyOnEachFailure = "ReportingNotificationNotifyOnEachFailure"
        static let notificationSlackChannels = "ReportingNotificationSlackChannels"
        static let notificationMSTeamsChannels = "ReportingNotificationMsTeamsChannels"
        static let notificationEmails = "ReportingNotificationEmails"
        static let milestoneId = "ReportingMilestoneId"
        static let milestoneName = "ReportingMilestoneName"
        static let debugLogsEnabled = "ReportingDebugLogsEnabled"
    }
    
    func getConfiguration() throws -> Configuration? {
        guard
            let bundlePath = self.testBundle.path(forResource: "Info", ofType: "plist"),
            let bundleProperties = NSDictionary(contentsOfFile: bundlePath) as? [String: Any],
            let isReportingEnabled = bundleProperties[Property.reportingEnabled] as? Bool
        else {
            return nil
        }
        guard isReportingEnabled else {
            return Configuration(isReportingEnabled: false)
        }
        guard let baseUrl = bundleProperties[Property.serverHostname] as? String else {
            throw ZebrunnerAgentError(description: "\(Property.reportingEnabled) property is TRUE, but mandatory \(Property.serverHostname) parameter is not defined")
        }
        guard let accessToken = bundleProperties[Property.serverAccessToken] as? String else {
            throw ZebrunnerAgentError(description: "\(Property.reportingEnabled) property is TRUE, but mandatory \(Property.serverAccessToken) parameter is not defined")
        }
        var configuration = Configuration(isReportingEnabled: isReportingEnabled,
                                          baseUrl: baseUrl,
                                          accessToken: accessToken)
        if let projectKey = bundleProperties[Property.projectKey] as? String {
            configuration.projectKey = projectKey
        }
        if let displayName = bundleProperties[Property.runDisplayName] as? String {
            configuration.displayName = displayName
        }
        if let config = buildConfig(bundleProperties: bundleProperties) {
            configuration.config = config
        }
        if let locale = bundleProperties[Property.runLocale] as? String {
            configuration.locale = locale
        }
        if let skipsAsFailures = bundleProperties[Property.runTreatSkipsAsFailures] as? Bool {
            configuration.skipsAsFailures = skipsAsFailures
        }
        if let milestone = buildMilestone(bundleProperties: bundleProperties) {
            configuration.milestone = milestone
        }
        if let notifications = buildNotifications(bundleProperties: bundleProperties) {
            configuration.notifications = notifications
        }
        if let isDebugLogsEnabled = bundleProperties[Property.debugLogsEnabled] as? Bool {
            configuration.isDebugLogsEnabled = isDebugLogsEnabled
        }
        return configuration
    }
    
    private func buildConfig(bundleProperties: [String: Any]) -> Config? {
        var config = Config()
        if let build = bundleProperties[Property.runBuild] as? String {
            config.build = build
        }
        if let environment = bundleProperties[Property.runEnvironment] as? String {
            config.environment = environment
        }
        return config.isInitialized() ? config : nil
    }
    
    private func buildMilestone(bundleProperties: [String: Any]) -> Milestone? {
        var milestone = Milestone()
        if let milestoneId = bundleProperties[Property.milestoneId] as? String {
            milestone.id = Int(milestoneId)
        }
        if let milestoneName = bundleProperties[Property.milestoneName] as? String {
            milestone.name = milestoneName
        }
        return milestone.isInitialized() ? milestone : nil
    }
    
    private func buildNotifications(bundleProperties: [String: Any]) -> Notifications? {
        var notifications = Notifications()
        notifications.targets = []
        if let notifyOnEachFailure = bundleProperties[Property.notificationNotifyOnEachFailure] as? Bool {
            notifications.notifyOnEachFailure = Bool(notifyOnEachFailure)
        }
        if let slackChannels = bundleProperties[Property.notificationSlackChannels] as? String {
            notifications.targets?.append(Target(type: .slack, value: slackChannels))
        }
        if let msTeamsChannels = bundleProperties[Property.notificationMSTeamsChannels] as? String {
            notifications.targets?.append(Target(type: .msTeams, value: msTeamsChannels))
        }
        if let emails = bundleProperties[Property.notificationEmails] as? String {
            notifications.targets?.append(Target(type: .email, value: emails))
        }
        return notifications.isInitialized() ? notifications : nil
    }
}
