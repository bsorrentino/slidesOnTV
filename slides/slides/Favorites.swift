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
        
        guard let _ = data[FavoriteItem.ITEMID], let _ = data[FavoriteItem.Title], let _ = data[FavoriteItem.DownloadUrl] else {
            return nil
        }
        
        self.data = data
        
    }

    
}


func favorites() -> [FavoriteItem] {
    let sequence = NSUbiquitousKeyValueStore.default.dictionaryRepresentation.enumerated()
    
    return sequence
        .compactMap { $0.element.value as? [String:String] }
        .compactMap { FavoriteItem( data: $0 ) }
    
}

func favoriteRemove( key:String, synchronize:Bool = false ) {

    NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
    
    if( synchronize ) {
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}

func favoriteAdd<T>( data:T, synchronize:Bool = false ) where T : SlideItem  {
            
    let key = data.id //NSUUID().uuidString
  
    var value = Dictionary<String,String>()
    
    if let url = data.downloadUrl?.absoluteString {
        value[FavoriteItem.DownloadUrl] = url
    }
    
    value[FavoriteItem.ITEMID]     = data.id
    value[FavoriteItem.Title]      = data.title
    value[FavoriteItem.Thumbnail]  = data.thumbnail

    NSUbiquitousKeyValueStore.default.set( value, forKey: key )
        
    if( synchronize ) {
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}

