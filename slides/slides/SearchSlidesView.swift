//
//  SearchSlides.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 02/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI
import Combine


fileprivate let Const = (
    gridItemSize:   CGFloat(500),
    
    Background: Color.blue
)

struct SearchSlidesView: View  {
    @StateObject var slidesResult       = SlideShareResult()
    @StateObject var downloadManager    = DownloadManager<SlidehareItem>()
    
    @State var isItemDownloaded:Bool    = false
    @State var selectedItem:SlidehareItem?
    
    let columns:[GridItem] = Array(repeating: .init(.fixed(Const.gridItemSize)), count: 3)
    
    /**
     *  NEXT PAGE VIEW
     */
    struct NextPageView : View {
        
        @Environment(\.isFocused) var focused: Bool
        
        var onFocusChange: (Bool) -> Void = { _ in }
        
        var body: some View {
            
            Label( "More Result ...", systemImage: "arrow.right.doc.on.clipboard" )
                .foregroundColor(.blue)
                .padding()
                .background(Color.white)
                .onChange(of: focused, perform: {
                    print( "NextPageView: old:\(focused) new:\($0)")
                    onFocusChange( $0 ) // Workaround for 'CardButtonStyle' bug
                })
        }
    }
    
    fileprivate func resetItem( OnFocusChange focused : Bool ) {
        if focused {
            self.selectedItem = nil
        }
    }
    
    fileprivate func setItem( item:SlidehareItem, OnFocusChange focused : Bool ) {
        if focused {
            self.selectedItem = item
        }
        else if( item == self.selectedItem ) {
            self.selectedItem = nil
        }
    }
    
    var body: some View {
        NavigationStack {
            
            VStack {
                //
                // @ref https://stackoverflow.com/a/67730429/521197
                //
                // ScrollViewReader usage for dynamically scroll to tagged position
                //
                ScrollView {
                    LazyVGrid( columns: columns ) {
                        
                        ForEach(slidesResult.data, id: \.id) { item in
                            
                            Button( action: {
                                Task {
                                    isItemDownloaded = 
                                        await self.downloadManager.download(item: item)
                                }
                            }) {
                                
                                SearchCardView<SlidehareItem>( item: item,
                                                               onFocusChange: setItem )
                                    .environmentObject(downloadManager)
                            }
                            .buttonStyle( CardButtonStyle() ) // 'CardButtonStyle' doesn't work whether .focusable() is called
                            .disabled( self.downloadManager.isDownloading(item: item) )
                            .id( item.id )
                            
                        }
                        if slidesResult.hasMoreItems {
                            Button( action: { slidesResult.nextPage() }) {
                                NextPageView( onFocusChange: resetItem )
                            }
                            .buttonStyle( CardButtonStyle() ) // 'CardButtonStyle' doesn't work whether .focusable() is called
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
                
                TitleView( selectedItem: selectedItem )
                
            }
            .edgesIgnoringSafeArea(.bottom)
            .searchable(text: $slidesResult.searchText)
            .navigationDestination(isPresented: $isItemDownloaded ) {
                PresentationView<SlidehareItem>()
                    .environmentObject(downloadManager)
            }
        }
        .searchTheme()
    }
    
}

#Preview {
    VStack {
        Button( action: {} ) {
            ZStack {
                Rectangle()
                    .fill( Color.white.opacity(0.5) )
                    .cornerRadius(10)
                    .shadow( color: Color.black, radius: 10 )
                
                ProgressView( "Download:", value: 0.5, total:1)
                    .progressViewStyle(BlueShadowProgressViewStyle())
                    .padding()
                
            }
        }
        .frame( width:500, height: 150)
        
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background( Color.white )
    
}


