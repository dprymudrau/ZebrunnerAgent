//
//  AuthResponse.swift
//  
//
//  Created by Dzmitry Prymudrau on 22.07.22.
//

import Foundation

public struct AuthResponse: Codable {
    var authToken: String
    var userId: Int
    var authTokenType: String
}
