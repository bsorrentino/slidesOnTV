//
//  Favourites.swift
//  slides
//
//  Created by softphone on 13/06/2017.
//  Copyright © 2017 soulsoftware. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias FavoriteData = ( key:String, value:Any )

func rxFavorites() -> Observable<FavoriteData> {
    let sequence = NSUbiquitousKeyValueStore.default().dictionaryRepresentation.enumerated()
    
    return Observable.from(sequence).map { (t) in return t.element }
    
}


func rxFavoriteStore( data:DocumentInfo ) -> Completable {
    
    return Completable.create { (completable) -> Disposable in
        
       let key = NSUUID().uuidString
        
       NSUbiquitousKeyValueStore.default().set( [ "url":data.url, "title":data.title ], forKey: key )
        
        completable(.completed)
        
        
        return Disposables.create {
        
            NSUbiquitousKeyValueStore.default().synchronize()
        }
    }
}
