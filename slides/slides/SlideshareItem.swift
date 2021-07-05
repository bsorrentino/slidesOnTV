//
//  SlideshareItem.swift
//  slides
//
//  Created by softphone on 04/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation


struct SlidehareItem : Identifiable {
    
    static let Title            = "title"
    static let DownloadUrl      = "downloadurl"
    static let ITEMID           = "id"
    static let URL              = "url" // permalink
    static let Created          = "created"
    static let Updated          = "updated"
    static let Format           = "format"
    static let Language         = "language"
    static let ThumbnailS       = "thumbnailsmallurl"
    static let ThumbnailXL      = "thumbnailxlargeurl"
    static let ThumbnailXXL     = "thumbnailxxlargeurl"
    
    static let names = [
        Title,
        DownloadUrl,
        ITEMID,
        URL,
        Updated,
        Format,
        ThumbnailXL,
        ThumbnailXXL,
        ThumbnailS,
        Created,
        Language
    ]
    
    let data:Slideshow
    
    var id: String {
        self.data[SlidehareItem.ITEMID]!
    }

    var thumbnailS: String {
        return "http:\(self.data[SlidehareItem.ThumbnailS]!)"
    }

    var thumbnailXL: String {
        "http:\(self.data[SlidehareItem.ThumbnailXL]!)"
    }

    var thumbnailXXL: String {
        "http:\(self.data[SlidehareItem.ThumbnailXXL]!)"
    }

}
