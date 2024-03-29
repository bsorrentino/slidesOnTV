//
//  Favorites.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 07/11/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation


struct FavoriteItem : SlideItem {
    
    static let ITEMID           = "id"
    static let Title            = "title"
    static let DownloadUrl      = "location"
    static let Thumbnail        = "thumbnail"
    static let Updated          = "updated"

    private let data:Slideshow
    
    // Identifiable
    var id: String          { data[FavoriteItem.ITEMID]! }
    var title: String       { data[FavoriteItem.Title]! }

    var updated: String?     { data[FavoriteItem.Updated] }
    var thumbnail: String?   { data[FavoriteItem.Thumbnail] }
    var downloadUrl: URL? {
        guard let result = self.data[FavoriteItem.DownloadUrl] else {
            return nil
        }
        return URL(string:result)
    }

    // Equatable
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    init?(data: Slideshow) {
        
        guard let _ = data[FavoriteItem.ITEMID], let _ = data[FavoriteItem.Title] /*, let _ = data[FavoriteItem.DownloadUrl]*/ else {
            return nil
        }
        
        self.data = data
        
    }
    
    init?<T>(item: T) where T : SlideItem {
        
        var value = Dictionary<String,String>()
        
        value[FavoriteItem.ITEMID]      = item.id
        value[FavoriteItem.Title]       = item.title
        value[FavoriteItem.DownloadUrl] = item.downloadUrl?.absoluteString
        value[FavoriteItem.Thumbnail]   = item.thumbnail

        self.init( data: value )
    }

    
}

extension NSUbiquitousKeyValueStore {

    func favorites() -> [FavoriteItem] {
        let sequence = self.dictionaryRepresentation.enumerated()
    
        return sequence
            .compactMap { $0.element }
            .compactMap {
                
                if let value = $0.value as? [String:String] {
                    let id = $0.key.trimmingCharacters(in: .whitespacesAndNewlines)
                    return [ "id":id ].merging( value ) { (first, _) in  first }
                }
                return nil
            }
            .compactMap { FavoriteItem( data: $0 ) }
            .sorted( by: { $0.title < $1.title } )
    
    }

    func favoriteRemove( key:String, synchronize:Bool = false ) {

        self.removeObject(forKey: key)
        
        if( synchronize ) {
            self.synchronize()
        }
    }

    func favoriteAdd<T>( data:T, synchronize:Bool = false ) where T : SlideItem  {
                
        let key = data.id //NSUUID().uuidString
      
        var value = Dictionary<String,String>()
        
        if let url = data.downloadUrl?.absoluteString {
            value[FavoriteItem.DownloadUrl] = url
        }
        
        value[FavoriteItem.ITEMID]      = data.id
        value[FavoriteItem.Title]       = data.title
        value[FavoriteItem.Thumbnail]   = data.thumbnail
        value[FavoriteItem.Updated]     = data.updated

       self.set( value, forKey: key )
            
        if( synchronize ) {
            self.synchronize()
        }
    }

}
