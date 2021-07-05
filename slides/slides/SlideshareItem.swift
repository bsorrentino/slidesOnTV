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

    var title: String {
        guard let result = self.data[SlidehareItem.Title] else {
            return ""
        }
        return result

    }

    var thumbnailS: String {
        guard let result = self.data[SlidehareItem.ThumbnailS] else {
            return ""
        }
        return "http:\(result)"
    }

    var thumbnailXL: String {
        guard let result = self.data[SlidehareItem.ThumbnailXL] else {
            return ""
        }
        return "http:\(result)"
    }

    var thumbnailXXL: String {
        guard let result = self.data[SlidehareItem.ThumbnailXXL] else {
            return ""
        }
        return "http:\(result)"
    }

}
