//
//  FavoritesView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 07/11/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI
import Combine

fileprivate let Const = (
    gridItemSize:   CGFloat(500),
    
    Background: Color.blue
)

struct FavoritesView: View {
    
    @StateObject var downloadManager = DownloadManager<FavoriteItem>()
    @State var isItemDownloaded:Bool    = false
    @State var selectedItem:FavoriteItem?
    @State private var data:[FavoriteItem] = []
    
    private let columns:[GridItem] = Array(repeating: .init(.fixed(Const.gridItemSize)), count: 3)
    
    private var cancellable: AnyCancellable?
    
    var body: some View {
        NavigationView {
            
            ZStack {
                NavigationLink(destination: PresentationView<FavoriteItem>()
                                                .environmentObject(downloadManager),
                               isActive: $isItemDownloaded) { EmptyView() }
                               .hidden()
                VStack {
                    
                    HStack(alignment: .center, spacing: 10 ) {
                        Image( systemName: "bookmark.fill")
                            .resizable()
                            .scaledToFit()
                            .frame( minWidth: 100, maxHeight: 70 )
                            
                        Text( "Favorites" )
                            .font(.largeTitle.bold())
                            
                    }.padding()
                    Divider()
                    //
                    // @ref https://stackoverflow.com/a/67730429/521197
                    //
                    // ScrollViewReader usage for dynamically scroll to tagged position
                    //
                    ScrollView {
                        LazyVGrid( columns: columns ) {
                            
                            ForEach(data, id: \.id) { item in
                                
                                Button( action: {
                                    self.downloadManager.downloadFavorite(item ) { isItemDownloaded = $0 }
                                }) {
                                        SearchCardView2<FavoriteItem>( item: item,
                                                                       onFocusChange: setItem )
                                            .environmentObject(downloadManager)
                                }
                                .buttonStyle( CardButtonStyle() ) // 'CardButtonStyle' doesn't work whether .focusable() is called
                                .disabled( self.downloadManager.isDownloading(item: item) )
                                .id( item.id )
                                
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    TitleView( selectedItem: selectedItem )
                }
                .onAppear {
                    data = NSUbiquitousKeyValueStore.default.favorites()
                }
                
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .favoritesTheme()
    }
    
    
    fileprivate func resetItem( OnFocusChange focused : Bool ) {
        if focused {
            self.selectedItem = nil
        }
    }
    
    fileprivate func setItem( item:FavoriteItem, OnFocusChange focused : Bool ) {
        if focused {
            self.selectedItem = item
        }
        else if( item == self.selectedItem ) {
            self.selectedItem = nil
        }
    }
    
}


extension DownloadManager where T == FavoriteItem {
    
    
    func downloadFavorite( _ item: FavoriteItem, completionHandler: @escaping (Bool) -> Void ) {
        
        guard let credentials = try? SlideshareApi.getCredential() else {
            return
        }

        let api = SlideshareApi()

        let parser = SlideshareItemsParser()

        if let query = try? api.queryById(credentials: credentials, id: item.id ) {

            let onCompletion = { (completion:Subscribers.Completion<Error>) in
                switch completion {
                case .failure(let error):
                    log.error( "\(error.localizedDescription)")
                case .finished:
                    log.debug("DONE!")
                }
            }

           query.toGenericError()
                .flatMap    { parser.parse($0.data) }
                .map        { SlidehareItem(data:$0) }
                .compactMap { FavoriteItem(item:$0) }
                .first()
                .sink(
                    receiveCompletion: onCompletion,
                    receiveValue: {
                        self.download(item: $0, completionHandler: completionHandler)
                    })
                .store(in: &bag)
        }
        else {
            log.error( "error invoking slideshare API" )
        }


    }
}


struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
