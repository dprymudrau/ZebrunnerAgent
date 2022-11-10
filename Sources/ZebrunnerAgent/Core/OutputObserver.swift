//
//  OutputObserver.swift
//  
//
//  Created by asukhodolova on 2.11.22.
//

import Foundation
import XCTest

class OutputObserver {
    
    private var testCaseName: String
    private var outputText: String
    private var launchMode: LaunchMode
    private var observer: AnyObject?
    private var timer: RepeatingTimer
    private let queue = DispatchQueue(label: "com.zebrunner.reporting")
    private let semaphore = DispatchSemaphore(value: 1)
    
    init(launchMode: LaunchMode) {
        self.launchMode = launchMode
        self.outputText = ""
        self.testCaseName = ""
        
        // timer for sending logs to Zebrunner in specified time interval
        self.timer = RepeatingTimer(timeInterval: 3)
        timer.eventHandler = {
            self.sendCapturedLogs()
        }
        
        subscribeToLogsInterruptionEvent()
        startInterception()
    }
    
    deinit {
        unsubscribeFromLogsInterruptionEvent()
    }
    
    /// Starts logs capture of executed test case
    /// - Parameter testCase: executed test case
    func startLogsCapture(testCase: XCTestCase) {
        self.testCaseName = testCase.name
        self.outputText = ""
        self.timer.resume()
    }
    
    /// FInishes logs capture of executed test case
    /// - Parameter testCase: executed test case
    func finishLogsCapture(testCase: XCTestCase) {
        self.timer.suspend()
        NotificationCenter.default.post(name: .interruptionInCapturedLogs, object: testCase)
    }
    
    /// Intercepts STDERR using outputPipe but still write to console output using inputPipe
    /// NOTE:
    /// STDERR - captures default XCTest logging, NSLog, unified logging such as Logger (from os module) and os_log
    /// STDOUT - captures print, debugPring and dump methods from standard library
    private func startInterception() {
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        
        // Copy STDOUT file descriptor to inputPipe for writing strings back to STDOUT to show as console output
        dup2(FileHandle.standardOutput.fileDescriptor, inputPipe.fileHandleForWriting.fileDescriptor)
        
        // Intercept STDERR with outputPipe
        dup2(outputPipe.fileHandleForWriting.fileDescriptor, FileHandle.standardError.fileDescriptor)
        
        if launchMode == .debug {
            // Intercept STDOUT in addition to STDERR
            dup2(outputPipe.fileHandleForWriting.fileDescriptor, FileHandle.standardOutput.fileDescriptor)
        }
        
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = outputPipe.fileHandleForReading.availableData
            var outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            if (outputString.starts(with: "Test Suite") || outputString.starts(with: "Test Case")){
                outputString = outputString.components(separatedBy: "started.\n").last ?? ""
            }
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
    private func sendCapturedLogs() {
        if self.outputText.isEmpty { return }
        
        queue.sync() {
            self.semaphore.wait()
            let currentOutput = self.outputText;
            self.outputText = ""
            self.semaphore.signal()
            
            let logsByLine = self.filterCapturedLogs(output: currentOutput)
            Artifact.sendLogs(self.testCaseName, logMessages: logsByLine, level: LogLevel.info, timestamp: Date().currentEpochUnixTimestamp())
        }
    }
    
    /// Separates by new lines and filter empty lines
    /// - Parameter output: captured logs as string
    /// - Returns: array of logs
    private func filterCapturedLogs(output: String) -> [String] {
        return output.replacingOccurrences(of: "XCTestOutputBarrier", with: "").components(separatedBy: .newlines).filter({ !$0.isEmpty})
    }
    
    /// Subscribes to logs interruption event
    private func subscribeToLogsInterruptionEvent() {
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(forName: .interruptionInCapturedLogs, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else {
                return
            }
            
            self.processNotification(notification: notification)
        }
    }
    
    /// Unsubscribes from logs interruption event
    private func unsubscribeFromLogsInterruptionEvent() {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
    
    /// Log interruption event processing. When this event happens (when screenshot is taken or test case is failed):
    /// sends to Zebrunner
    /// - logs that were captured so far
    /// - object that caused log interruption: screenshot or error
    /// - Parameter notification: notification from log interruption event
    private func processNotification(notification: Notification) {
        sendCapturedLogs()
        if let screenshot = notification.object as? XCUIScreenshot {
            queue.sync() {
                Screenshot.sendScreenshot(self.testCaseName, screenshot: screenshot)
            }
        } else if let issue = notification.object as? XCTIssue {
            queue.sync() {
                Artifact.sendLogs(self.testCaseName, logMessages: [issue.compactDescription], level: LogLevel.error, timestamp: Date().currentEpochUnixTimestamp())
            }
        } else if let testCase = notification.object as? XCTestCase {
            print("Logs collection has been finished for: ", testCase.name)
        } else {
            print("Undefined type of notification object, nothing will be performed")
        }
    }
}

extension Notification.Name {
    static let interruptionInCapturedLogs = NSNotification.Name("interruptionInCapturedLogs")
}
