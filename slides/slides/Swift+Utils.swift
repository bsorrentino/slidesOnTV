//
//  Swift+Utils.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 20/12/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
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
