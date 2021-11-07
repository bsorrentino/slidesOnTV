//
//  FavoritesView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 07/11/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

fileprivate let Const = (
    gridItemSize:   CGFloat(500),
    
    Background: Color.blue
)

struct FavoritesView: View {
    
    @StateObject var downloadManager = DownloadManager<FavoriteItem>()
    @State var isItemDownloaded:Bool    = false
    @State var selectedItem:FavoriteItem?
    @State var data = favorites()
    
    let columns:[GridItem] = Array(repeating: .init(.fixed(Const.gridItemSize)), count: 3)
    
    var body: some View {
        NavigationView {
            
            ZStack {
                NavigationLink(destination: PresentationView<SlidehareItem>().environmentObject(downloadManager),
                               isActive: $isItemDownloaded) { EmptyView() }
                    .hidden()
                VStack {
                        //
                        // @ref https://stackoverflow.com/a/67730429/521197
                        //
                        // ScrollViewReader usage for dynamically scroll to tagged position
                        //
                        ScrollView {
                                LazyVGrid( columns: columns ) {
                                    
                                    ForEach(data, id: \.id) { item in
                                        
                                        SearchCardView<FavoriteItem>( item: item,
                                                                       isItemDownloaded: $isItemDownloaded,
                                                                       onFocusChange: setItem )
                                            .environmentObject(downloadManager)
                                            .id( item.id )
                                            
                                    }
                                }

                        }
                        .padding(.horizontal)

                    }
                    Spacer()
                    TitleView( selectedItem: selectedItem )
                        
                        
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .main( gradient: Gradient(colors: [.black, .white]) )
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

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
