//
//  XCZebrunnerTestCase.swift
//  
//
//  Created by Dzmitry Prymudrau on 22.07.22.
//

import Foundation
import XCTest

open class XCZebrunnerTestCase: XCTestCase {
    //Can be added to the method to display maintainer on Zebrunner
    public var methodMaintainer = "anonymous"
    
    //Can be used in test case func to attach screenshot on Zebrunner
    public func attachScreenshot(screenshot: XCUIScreenshot) {
        ZebrunnerApiClient.shared?.sendScreenshot(self, screenshot: screenshot.pngRepresentation)
    }
}
