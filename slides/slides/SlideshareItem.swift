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
    static let Url              = "url" // permalink
    static let Created          = "created"
    static let Updated          = "updated"
    static let Format           = "format"
    static let Language         = "language"
    static let ThumbnailS       = "thumbnailsmallurl"
    static let ThumbnailXL      = "thumbnailxlargeurl"
    static let ThumbnailXXL     = "thumbnailxxlargeurl"
    
    static let Query        = "query"
    static let ResultOffset = "resultoffset"
    static let NumResults   = "numresults"
    static let TotalResults = "totalresults"

    static let Message = "message"

    static let names = [
        Title,
        DownloadUrl,
        ITEMID,
        Url,
        Updated,
        Format,
        ThumbnailXL,
        ThumbnailXXL,
        ThumbnailS,
        Created,
        Language,
        // META
        Query,
        ResultOffset,
        NumResults,
        TotalResults,
        // Error
        Message

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
    var downloadUrl: URL? {
        guard let result = self.data[SlidehareItem.DownloadUrl] else {
            return nil
        }
        return URL(string:result)

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
