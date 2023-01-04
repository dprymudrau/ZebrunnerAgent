//
//  TestArtifact.swift
//  
//
//  Created by Dzmitry Prymudrau on 27.07.22.
//

import Foundation

public struct AttachmentLabelDTO: Codable {
    var items: [LabelDTO]
}

public struct AttachmentArtifactDTO: Codable {
    var items: [ArtifactDTO]
}

public struct ArtifactDTO: Codable {
    var name: String
    var value: String
}

public struct LabelDTO: Codable {
    var key: String
    var value: String
}

public struct LogDTO: Codable {
    var testId: String
    var level: LogLevel
    var message: String
    var timestamp: String
}

enum CodingKeys: String, CodingKey {
    case items = "items"
}
