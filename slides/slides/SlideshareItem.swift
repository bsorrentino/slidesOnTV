//
//  SlideshareItem.swift
//  slides
//
//  Created by softphone on 04/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import UIKit

struct SlidehareItem : Identifiable {
    
    static let Title            = "title"
    static let DownloadUrl      = "downloadurl"
    static let ITEMID           = "id"
    static let Url              = "url" // permalink
    static let Created          = "created"
    static let Updated          = "updated"
    static let Format           = "format"
    static let Language         = "language"
    static let Thumbnail        = "thumbnailurl"
    static let ThumbnailSize    = "thumbnailsize"
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
        Thumbnail,
        ThumbnailSize,
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
    
    let thumbnailSize: CGSize

    init( data:Slideshow ) {
        self.data = data
        
        if let result = data[SlidehareItem.ThumbnailSize],
           let value = result.data( using: .utf8),
           let points = try? JSONDecoder().decode([Int].self, from: value ) {
           
            thumbnailSize =  CGSize( width: points[0], height: points[1] )
        }
        else {

            thumbnailSize = CGSize(width:170, height: 130)

        }
        print( "thumbnailSize: \(thumbnailSize)" )

    }
    
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

    var thumbnail: String {
        guard let result = self.data[SlidehareItem.Thumbnail] else {
            return ""
        }
        return "http:\(result)"
    }
    
}
