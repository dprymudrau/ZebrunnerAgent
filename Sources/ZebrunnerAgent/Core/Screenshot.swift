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
    
    public static func sendScreenshot(_ testCaseName: String, screenshot: XCUIScreenshot) {
        try? ZebrunnerApiClient.getInstance().sendScreenshot(testCaseName, screenshot: screenshot.pngRepresentation)
    }
    
    
    public static func sendScreenshot(_ testCaseName: String, screenshot: Data?) {
        try? ZebrunnerApiClient.getInstance().sendScreenshot(testCaseName, screenshot: screenshot)
    }
    
}
