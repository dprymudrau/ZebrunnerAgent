//
//  Element.swift
//  
//
//  Created by Dzmitry Prymudrau on 25.07.22.
//

import Foundation
import XCTest

open class ZebrunnerXCUIelement: XCUIElement {
    public override func tap() {
        ZebrunnerLogging.shared?.addLog(level: .info, message: "Tap on \(self.identifier)")
        super.tap()
    }
}
