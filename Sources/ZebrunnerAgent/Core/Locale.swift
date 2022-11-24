//
//  Locale.swift
//  
//
//  Created by asukhodolova on 8.11.22.
//

import Foundation

public class Locale {
    
    static let localeKey = "com.zebrunner.app/sut.locale";
    
    private init() {}
    
    /// Sets a locale for test run
    /// - Parameter localeValue: locale
    public static func setLocale(localeValue: String) {
        Label.attachToTestRun(key: localeKey, value: localeValue)
    }
}
