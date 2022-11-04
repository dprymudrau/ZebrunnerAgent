//
//  OutputObserver.swift
//  
//
//  Created by asukhodolova on 2.11.22.
//

import Foundation
import XCTest

class OutputObserver {
    
    private var observer: AnyObject?
    private var testCaseName: String
    private var outputText: String
    
    init(testCaseName: String) {
        self.testCaseName = testCaseName
        self.outputText = ""
    }
    
    deinit {
        unsubscribeFromLogsInterruptionEvent()
    }
    
    /// Intercepts STDERR using outputPipe but still write to console output using inputPipe
    /// NOTE:
    /// STDERR - captures default XCTest logging, NSLog, unified logging such as Logger (from os module) and os_log
    /// STDOUT - captures print, debugPring and dump methods from standard library
    func captureConsoleOutput() {
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        // In case of capturing STDOUT, use standatdOutput instead of standardError
        
        // Copy STDERR file descriptor to inputPipe for writing strings back to STDERR
        dup2(FileHandle.standardError.fileDescriptor, inputPipe.fileHandleForWriting.fileDescriptor)
        
        // Intercept STDERR with outputPipe
        dup2(outputPipe.fileHandleForWriting.fileDescriptor, FileHandle.standardError.fileDescriptor)
        
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText
                let nextOutput = previousOutput + outputString
                self.outputText = nextOutput
            })
            
            inputPipe.fileHandleForWriting.write(output)
            outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }
    
    /// Sends captured logs to Zebrunner
    func sendCapturedLogs(){
        let logsByLine = self.outputText.replacingOccurrences(of: "XCTestOutputBarrier", with: "").components(separatedBy: .newlines).filter({ !$0.isEmpty})
        Artifact.sendLogs(self.testCaseName, logMessages: logsByLine, level: LogLevel.info, timestamp: Date().currentEpochUnixTimestamp())
    }
    
    /// Subscribes to logs interruption event
    func subscribeToLogsInterruptionEvent() {
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(forName: .interruptionInCapturedLogs, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else {
                return
            }
            
            self.processNotification(notification: notification)
        }
    }
    
    /// Unsubscribes from logs interruption event
    func unsubscribeFromLogsInterruptionEvent() {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
    
    /// Log interruption event processing. When this event happens (when screenshot is taken or test case is failed):
    /// 1. sends to Zebrunner
    /// - logs that were captured so far
    /// - object that caused log interruption: screenshot or error
    /// 2. clear captured output
    /// - Parameter notification: notification from log interruption event
    private func processNotification(notification: Notification) {
        sendCapturedLogs()
        if let screenshot = notification.object as? XCUIScreenshot {
            Screenshot.sendScreenshot(self.testCaseName, screenshot: screenshot)
        }
        else if let issue = notification.object as? XCTIssue{
            Artifact.sendLogs(self.testCaseName, logMessages: [issue.compactDescription], level: LogLevel.error, timestamp: Date().currentEpochUnixTimestamp())
        }
        else {
            print("Undefined type of notification object, nothing will be performed")
        }
        self.outputText = ""
    }
}

extension Notification.Name {
    static let interruptionInCapturedLogs = NSNotification.Name("interruptionInCapturedLogs")
}
