//
//  AttachementDTO.swift
//  
//
//  Created by Dzmitry Prymudrau on 27.07.22.
//

import Foundation

public struct AttachementLabelDTO: Codable {
    var items: [LabelDTO]
}

public struct AttachementArtifactDTO: Codable {
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

enum CodingKeys: String, CodingKey {
    case items = "items"
}
