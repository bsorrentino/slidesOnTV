//
//  Utils.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 13/04/2020.
//  Copyright © 2020 soulsoftware. All rights reserved.
//

import Foundation


protocol NameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

extension NameDescribable {
    var typeName: String {
        return String(describing: type(of: self))
    }

    static var typeName: String {
        return String(describing: self)
    }
}


func associatedObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
        if let associated = objc_getAssociatedObject(base, key)
            as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated,
                                 .OBJC_ASSOCIATION_RETAIN)
        return associated
}

func associateObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
    objc_setAssociatedObject(base, key, value,
                             .OBJC_ASSOCIATION_RETAIN)
}
func describing( _ fh: UIFocusHeading ) -> String {
    switch( fh ) {
    case UIFocusHeading.up: return "up"
    case UIFocusHeading.down: return "down"
    case UIFocusHeading.left: return "down"
    case UIFocusHeading.right: return "right"
    case UIFocusHeading.next: return "next"
    case UIFocusHeading.previous: return "previous"
    default:return "undef"
    }
}


// Make String confrom to Error protocol
extension String: Error {}

