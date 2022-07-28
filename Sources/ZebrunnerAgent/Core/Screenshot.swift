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
    
    public static func sendScreenshot(_ testCase: String, screenshot: XCUIScreenshot) {
        try? ZebrunnerApiClient.getInstance().sendScreenshot(testCase, screenshot: screenshot.pngRepresentation)
    }
    
    
    public static func sendScreenshot(_ testCase: String, screenshot: Data?) {
        try? ZebrunnerApiClient.getInstance().sendScreenshot(testCase, screenshot: screenshot)
    }
    
}
