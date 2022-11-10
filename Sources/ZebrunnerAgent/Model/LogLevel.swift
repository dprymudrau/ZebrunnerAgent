//
//  LogLevel.swift
//  
//
//  Created by asukhodolova on 2.11.22.
//

import Foundation

public enum LogLevel: String, Codable {
    case trace = "TRACE"
    case debug = "DEBUG"
    case info = "INFO"
    case warn = "WARN"
    case error = "ERROR"
    case fatal = "FATAL"
}
