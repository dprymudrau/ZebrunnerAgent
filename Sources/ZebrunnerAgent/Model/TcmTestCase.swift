//
//  TcmTestCase.swift
//  
//
//  Created by asukhodolova on 18.11.22.
//

import Foundation

public struct TcmTestCaseResultDTO: Codable {
    var tcmType: TcmType
    var testCaseId: String
    var resultStatus: String
}

public struct TcmTestCasesDTO: Codable {
    var testCases: [TcmTestCaseResultDTO]
}
