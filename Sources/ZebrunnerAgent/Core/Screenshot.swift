//
//  Screenshot.swift
//  
//
//  Created by Dzmitry Prymudrau on 27.07.22.
//

import Foundation
import XCTest

public class Screenshot {
    private init() {}
    
    /// Sends a screenshot to Zebrunner
    /// - Parameters:
    ///   - testCase: test case name
    ///   - screenshot: taken screenshot
    public static func sendScreenshot(_ testCase: String, screenshot: XCUIScreenshot) {
        try? ZebrunnerApiClient.getInstance().sendScreenshot(testCase, screenshot: screenshot.pngRepresentation)
    }
    
    
    /// Sends a screenshot to Zebrunner
    /// - Parameters:
    ///   - testCase: test case name
    ///   - screenshot: taken screenshot
    public static func sendScreenshot(_ testCase: String, screenshot: Data?) {
        try? ZebrunnerApiClient.getInstance().sendScreenshot(testCase, screenshot: screenshot)
    }
    
}
