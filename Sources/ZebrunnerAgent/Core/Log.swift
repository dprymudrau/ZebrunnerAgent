//
//  Log.swift
//  
//
//  Created by asukhodolova on 8.11.22.
//

import Foundation

public class Log {
    private init() {}
    
    /// Sends log messages for certain test case to Zebrunner
    /// - Parameters:
    ///   - testCase: test case name
    ///   - logMessages: array of log messages
    ///   - level: log level
    ///   - timestamp: timestamp in Epoch Unix format
    public static func sendLogs(_ testCase: String, logMessages: [String], level: LogLevel, timestamp: String) {
        try? ZebrunnerApiClient.getInstance().sendLogs(testCaseName: testCase,
                                                       logMessages: logMessages,
                                                       level: level,
                                                       timestamp: timestamp)
    }
}
