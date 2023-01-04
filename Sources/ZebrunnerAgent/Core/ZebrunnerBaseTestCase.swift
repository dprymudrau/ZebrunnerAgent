//
//  ZebrunnerBaseTestCase.swift
//  
//
//  Created by Dzmitry Prymudrau on 22.07.22.
//

import Foundation
import XCTest

open class ZebrunnerBaseTestCase: XCTestCase {
    
    public override func record(_ issue: XCTIssue) {
        takeScreenshot()
        super.record(issue)
    }
}

extension XCTestCase {
    
    private static let association = ObjectAssociation<NSString>()
    
    public var testMaintainer: NSString {
        get {
            return XCTestCase.association[self] ?? "anonymous"
        }
        set(newValue) {
            XCTestCase.association[self] = newValue
        }
    }
    
    /// Creates an attachment of the screenshot in XCUI report and Zebrunner
    /// - Parameters:
    ///   - screenshot: taken screenshot
    ///   - name: display name of screenshot in XCUI report
    public func takeScreenshot(screenshot: XCUIScreenshot, name: String = "screenshot") {
        NotificationCenter.default.post(name: .interruptionInCapturedLogs, object: screenshot)

        let screenshotAttachment = XCTAttachment(screenshot: screenshot)
        let timestamp = Int(Date().timeIntervalSince1970)
        let screenshotName = "\(name)-\(timestamp).png"
        screenshotAttachment.name = screenshotName
        screenshotAttachment.lifetime = .keepAlways
        add(screenshotAttachment)
    }
    
    /// Takes a full screenshot of the current screen
    public func takeScreenshot() {
        let fullScreenshot = XCUIScreen.main.screenshot()
        takeScreenshot(screenshot: fullScreenshot)
    }
}

fileprivate final class ObjectAssociation<T: AnyObject> {
    
    private let policy: objc_AssociationPolicy
    
    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        
        self.policy = policy
    }
    
    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: AnyObject) -> T? {
        
        get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T? }
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }
}
