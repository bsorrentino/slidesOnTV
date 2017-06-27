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

func favoriteRemove( key:String, synchronize:Bool = false ) {

    NSUbiquitousKeyValueStore.default().removeObject(forKey: key)
    
    if( synchronize ) {
        NSUbiquitousKeyValueStore.default().synchronize()
    } 
}

func rxFavoriteRemove( key:String ) -> Completable {

    return Completable.create { (completable) -> Disposable in
        
        NSUbiquitousKeyValueStore.default().removeObject(forKey: key)
        completable(.completed)
        
        
        return Disposables.create {
            
            NSUbiquitousKeyValueStore.default().synchronize()
        }
    }

}

func rxFavoriteStore( data:DocumentInfo ) -> Completable {
    
    return Completable.create { (completable) -> Disposable in
        
       let key = data.id //NSUUID().uuidString
        
       NSUbiquitousKeyValueStore.default().set(
        [ "dummy":"", "title":data.title ],
        forKey: key )
        
        completable(.completed)
        
        
        return Disposables.create {
        
            NSUbiquitousKeyValueStore.default().synchronize()
        }
    }
}
