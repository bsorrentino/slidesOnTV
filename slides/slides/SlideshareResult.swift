//
//  SlideshareResult.swift
//  slides
//
//  Created by softphone on 04/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import Combine

class SlideShareResult :  ObservableObject {
    
    @Published var searchText = ""
    @Published var data = [SlidehareItem]()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var cancellable: AnyCancellable?
    
    private func onCompletion( completion:Subscribers.Completion<Error> ) {
        switch completion {
        case .failure(let error):
            log.error( "\(error.localizedDescription)")
        case .finished:
            log.debug("DONE!")
        }
    }
    
    /**
    @ref https://stackoverflow.com/a/66165075/521197
     */
    init() {
        $searchText
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .sink(receiveValue: { text in
                self.query(searchText: text)
            })
            .store(in: &subscriptions)
        
    }
    
    func query( searchText: String ) -> Void {
        
        if isInPreviewMode {
            
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00000"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00001"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00002"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00003"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00004"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00005"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00006"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00007"] ))
            
            return
        }

        let credentials = try? SlideshareApi.getCredential()

        let api = SlideshareApi()
        
        let parser = SlideshareItemsParser()
        
        if let query = try? api.query(credentials: credentials!, query:searchText) {
           
            self.data.removeAll()
            
            cancellable =
                query.toGenericError()
                    .flatMap( { parser.parse($0.data) } )
                    .filter({ $0[SlidehareItem.Format]=="pdf" })
                    //.receive(on: RunLoop.main )
                    .sink(
                        receiveCompletion: onCompletion,
                        receiveValue: {
                            // log.trace( "\($0)")
                            self.data.append( SlidehareItem(data:$0) )
                            //self.objectWillChange.send()
                        })
        }
        else {
            log.error( "error invoking slideshare API" )
        }
    }
    
}
