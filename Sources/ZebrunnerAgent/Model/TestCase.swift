//
//  TestCase.swift
//  
//
//  Created by Dzmitry Prymudrau on 22.07.22.
//

import Foundation

public struct TestCaseStartDTO {
    var name: String
    var className: String
    var methodName: String
    var startTime: String
    var maintainer: String = "anonymous"
    var argumentsIndex: Int = 0
}

public struct TestCaseUpdateDTO {
    var name: String
    var className: String
    var methodName: String
    var maintainer: String = "anonymous"
    var argumentsIndex: Int = 0
}

public struct TestCaseFinishDTO {
    var result: TestStatus
    var endTime: String
    var reason: String?
}

public struct TestCaseStartResponse: Codable {
    var name: String
    var id: Int
}
