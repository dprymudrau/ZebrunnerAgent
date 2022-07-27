//
//  ZebrunnerAgentError.swift
//  
//
//  Created by Dzmitry Prymudrau on 27.07.22.
//

import Foundation

struct ZebrunnerAgentError: LocalizedError {
    var title: String
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }
    
    private var _description: String
    
    init(title: String = "ZebrunnerAgentError", description: String) {
        self.title = title
        self._description = description
    }
    
    
}
