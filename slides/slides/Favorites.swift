//
//  Favorites.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 07/11/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation

typealias FavoriteData = ( key:String, value:[String:String]? )


struct FavoriteItem : SlideItem {
    private let data:Slideshow
    
    // Identifiable
    var id: String          { data["id"]! }
    var title: String       { data["title"]! }
    var thumbnail: String   { data["thumbnail"]! }

    var downloadUrl: URL? {
        guard let result = self.data["downloadurl"] else {
            return nil
        }
        return URL(string:result)
    }

    // Equatable
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    init?(data: Slideshow) {
        
        guard let _ = data["id"], let _ = data["title"], let _ = data["thumbnail"] else {
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
        value["downloadurl"] = url
    }
    
    value["id"]         = data.id
    value["thumbnail"]  = data.thumbnail
    value["title"]      = data.title

    NSUbiquitousKeyValueStore.default.set( value, forKey: key )
        
    if( synchronize ) {
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}

