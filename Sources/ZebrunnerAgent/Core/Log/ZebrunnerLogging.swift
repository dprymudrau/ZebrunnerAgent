//
//  ZebrunnerLogging.swift
//  
//
//  Created by Dzmitry Prymudrau on 25.07.22.
//

import Foundation

public class ZebrunnerLogging {
    
    private var logsBucket: [[String: AnyHashable]] = [[:]]
    private var testId: Int
    private var timeInterval = 30.0
    private var timer: Timer?
    public static var shared: ZebrunnerLogging?
    
    private init(testCaseName: String) {
        self.testId = (ZebrunnerApiClient.shared?.getTestCaseId(for: testCaseName))!
    }
    
    public static func setUp(testCaseName: String) -> ZebrunnerLogging {
        if (shared == nil) {
            self.shared = ZebrunnerLogging(testCaseName: testCaseName)
        }
        return self.shared!
    }
    
    @available(macOS 10.12, *)
    public func startLogsSending() {
        timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true) {_ in
            self.sendToBackendIfNeeded()
        }
    }
    
    public func addLog(level: LogLevel, message: String) {
        let zebrunnerLogMessage = [
            "testId": self.testId,
            "level": level.rawValue,
            "timestamp": NSDate().timeIntervalSince1970,
            "message": message
        ] as [String: AnyHashable]
        logsBucket.append(zebrunnerLogMessage)
    }
    
    private func sendToBackendIfNeeded() {
        if !logsBucket.isEmpty {
            ZebrunnerApiClient.shared?.sendLogs(logs: logsBucket)
        }
        logsBucket.removeAll()
    }
    
    public func stopLogsSending() {
        timer?.invalidate()
        timer = nil
        sendToBackendIfNeeded()
    }
    
}
