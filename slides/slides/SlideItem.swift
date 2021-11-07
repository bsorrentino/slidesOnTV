//
//  Slideitem.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 07/11/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation

typealias Slideshow = [String:String]

protocol SlideItem : Identifiable, Equatable {

    var id: String { get }
    
    var title: String { get }
    var downloadUrl: URL? { get }
    var thumbnail: String { get }
//    var created: String { get }
    var updated: String { get }
    
    init?(data: Slideshow)
}
