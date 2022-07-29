//
//  XCZebrunnerTestCase.swift
//  
//
//  Created by Dzmitry Prymudrau on 22.07.22.
//

import Foundation
import XCTest

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
