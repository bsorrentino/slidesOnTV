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

    private(set) var totalItems:Int = 0
    private(set) var currentPage:Int = 1

    private var subscriptions = Set<AnyCancellable>()

    private var cancellable: AnyCancellable?

    var hasMoreItems:Bool {
        totalItems > data.count
    }

    /**
    @ref https://stackoverflow.com/a/66165075/521197
     */
    init() {
        $searchText
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .sink(receiveValue: { text in
                self.reset()
                self.query(searchText: text)
            })
            .store(in: &subscriptions)

    }

    private func reset() {
        totalItems  = 0
        currentPage = 1
        data.removeAll()
    }

    func nextPage() {
        if( hasMoreItems ) {

            currentPage += 1
            query( searchText: searchText )
        }
    }

    func query( searchText: String ) -> Void {

        if isInPreviewMode {

            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00000", SlidehareItem.Title:"Title for 000000"] ))
            data.append( SlidehareItem( data:[
                                        SlidehareItem.ITEMID:"00001",
                                            SlidehareItem.Title: """
                                            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse facilisis tincidunt sapien eget euismod. Aenean vulputate ligula a orci molestie malesuada. Phasellus tempus tincidunt turpis eu finibus. Aliquam tempus aliquam.
                                            """]))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00002"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00003"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00004"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00005"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00006"] ))
            data.append( SlidehareItem( data:[SlidehareItem.ITEMID:"00007"] ))

            totalItems = 1000
            return
        }

        if searchText.isEmpty  {
            log.trace( "search is empty")
            return
        }

        let credentials = try? SlideshareApi.getCredential()

        let api = SlideshareApi()

        let parser = SlideshareItemsParser()

        if let query = try? api.query(credentials: credentials!, query:searchText, page:currentPage) {

            let onCompletion = { (completion:Subscribers.Completion<Error>) in
                switch completion {
                case .failure(let error):
                    log.error( "\(error.localizedDescription)")
                case .finished:
                    self.totalItems = parser.meta?.TotalResults ?? 0
                    log.debug("DONE! total:\(self.totalItems) - current: \(self.data.count)")
                }
            }

            // Chunck Array
            // @ref https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
            //
            /*
            extension Array {
                func chunked(into size: Int) -> [[Element]] {
                    return stride(from: 0, to: count, by: size).map {
                        Array(self[$0 ..< Swift.min($0 + size, count)])
                    }
                }
            }
            */

            //let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

            cancellable =
                query.toGenericError()
                .flatMap    { parser.parse($0.data) }
                .filter     { $0[SlidehareItem.Format]=="pdf" }
                .map        { SlidehareItem(data:$0) }
                .collect()
                //.flatMap { timer.zip( $0.publisher ).map { $0.1 } }
                .sink(
                    receiveCompletion: onCompletion,
                    receiveValue: {
                        //log.trace( "\($0.title)")
                        self.data.append( contentsOf: $0 )
                    })
        }
        else {
            log.error( "error invoking slideshare API" )
        }
    }

}