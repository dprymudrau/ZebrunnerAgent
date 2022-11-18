//
//  TestRun.swift
//  
//
//  Created by Dzmitry Prymudrau on 22.07.22.
//

import Foundation

public struct TestRunStartDTO: Codable {
    var name: String
    var startTime: String
    var framework: String = "XCTest"
    var config: Config?
    var milestone: Milestone?
    var notifications: Notifications?
    
    enum CodingKeys: String, CodingKey {
        case name
        case startTime  = "startedAt"
        case framework
        case config
        case milestone
        case notifications
    }
}

public struct Config: Codable {
    var build: String?
    var environment: String?
    
    func isInitialized() -> Bool {
        return build != nil || environment != nil
    }
}

public struct Milestone: Codable {
    var id: Int?
    var name: String?
    
    func isInitialized() -> Bool {
        return id != nil || name != nil
    }
}

public struct Notifications: Codable {
    var notifyOnEachFailure: Bool?
    var targets: [Target]?
    
    func isInitialized() -> Bool {
        return notifyOnEachFailure != nil || (targets != nil && !targets!.isEmpty)
    }
}

public struct Target: Codable {
    var type: NotificationTarget
    var value: String
}

enum NotificationTarget: String, Codable {
    case slack = "SLACK_CHANNELS"
    case msTeams = "MS_TEAMS_CHANNELS"
    case email = "EMAIL_RECIPIENTS"
}

public struct TestRunFinishDTO: Codable {
    var endTime: String
}

public struct TestRunStartResponse: Codable {
    var id: Int
    var uuid: String
}
