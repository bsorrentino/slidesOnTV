//
//  PresentationView.swift
//  slides
//
//  Created by softphone on 13/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

struct PresentationView<T>: View where T : SlideItem {
    
    @EnvironmentObject var downloadInfo:DownloadManager<T>
    @State var isZoom = false
    @State var pageSelected: Int = 1

    
    func saveToFavorites() {
        
        if let item = downloadInfo.downdloadedItem {
            NSUbiquitousKeyValueStore.default.favoriteAdd(data: item, synchronize: true)
        }
    }
    
    
    func ToolbarModifierForFavorite<Content:View>( _ content: Content) -> some View {
        
        content
        .navigationTitle("")
        .toolbar {
            
            ToolbarItem(placement: .primaryAction) {
                Button( action: { isZoom.toggle() } ) {
                                Image( systemName: "arrow.up.left.and.arrow.down.right")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .frame(width: 25.0, height: 25.0)
                                    //.padding( .top, 40 )
                            }
            }
                
        }

    }

    func ToolbarModifierForSlide<Content:View>( _ content: Content) -> some View {
        
        content
        .navigationTitle("")
        .toolbar {
            
            ToolbarItem(placement: .primaryAction) {
                Button( action: { isZoom.toggle() } ) {
                                Image( systemName: "arrow.up.left.and.arrow.down.right")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .frame(width: 25.0, height: 25.0)
                                    //.padding( .top, 40 )
                            }
            }
                
            ToolbarItem(placement: .confirmationAction) {
                Button( action: saveToFavorites ) { //
                    Image( systemName: "bookmark")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .frame(width: 25, height: 25)
                        //.padding( .top, 40 )
                }
            }
        }

    }
    
    private func ToolbarModifier<Content:View>( _ content: Content) -> some View {
        
        Group {
            if downloadInfo.downdloadedItem is FavoriteItem {
                ToolbarModifierForFavorite( content )
            }
            else {
                ToolbarModifierForSlide( content )
            }
        }
    }
    
    var body: some View {
        NavigationView {
            if let doc = downloadInfo.downloadedDocument {
                PDFReaderContentView( document: doc, pageSelected: $pageSelected, isZoom: isZoom )
                    .if( isZoom ) { $0.onExitCommand { isZoom.toggle() } }
                    .if( !isZoom , modifier: ToolbarModifier )
                    .if( isZoom ) { $0.edgesIgnoringSafeArea( .all ) }
            }
            else {
                Text( "error loading presentation")
            }
        }

    }
}

//struct PresentationView_Previews: PreviewProvider {
//    static var previews: some View {
//        PresentationView()
//    }
//}
