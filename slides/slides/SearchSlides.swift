//
//  SearchSlides.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 02/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Combine


fileprivate let Const = (
    gridItemSize:   CGFloat(500),
    
    cardSize:       CGSize( width: 490, height: 300 ),
    
    ProgressView: (fill:Color.white.opacity(0.5),  radius:CGFloat(10)),
    
    Background: Color.blue
)

struct SearchSlidesView: View {
    @StateObject var slidesResult       = SlideShareResult()
    @StateObject var downloadManager    = DownloadManager()
    
    @State var isItemDownloaded:Bool    = false
    @State var selectedItem:SlidehareItem?
    
    let columns:[GridItem] = Array(repeating: .init(.fixed(Const.gridItemSize)), count: 3)

    func DownloadProgressView() -> some View {
        
        ZStack {
            Rectangle()
                .fill( Const.ProgressView.fill )
                .cornerRadius(Const.ProgressView.radius)
                .shadow( color: Color.black, radius: Const.ProgressView.radius )

            ProgressView( "Download: \(self.downloadManager.downloadingDescription)", value: self.downloadManager.downloadProgress?.0, total:1)
                .progressViewStyle(BlueShadowProgressViewStyle())
                .padding()
                
        }
    }
    
    struct ThumbnailView : View {
        @Environment(\.isFocused) var focused: Bool
        
        var item: SlidehareItem
        var onFocusChange: (SlidehareItem,Bool) -> Void = { _,_ in }

        var body: some View {
        
            Group {
                if( isInPreviewMode ) {
                    Image("slideshow")
                        .resizable()
                        .scaledToFit()
                }
                else {
                    WebImage(url: URL(string: item.thumbnail) )
                        // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
                        .onSuccess { image, data, cacheType in
                            // Success
                            // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                            // print( "ThumbnailView: \(focused) - \(item.title)")
                        }
                        .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                        .placeholder(Image(systemName: "photo")) // Placeholder Image
                        // Supports ViewBuilder as well
                        .placeholder {
                            Rectangle().foregroundColor(.gray)
                        }
                        .indicator(.activity) // Activity Indicator
                        .transition(.fade(duration: 0.5)) // Fade Transition with duration
                        .scaledToFit()
                }
            }
            .onChange(of: focused, perform: {
                print( "ThumbnailView(\(item.title)): old:\(focused) new:\($0)")
                onFocusChange( item, $0 ) // Workaround for 'CardButtonStyle' bug
            })
//            .frame(width: item.thumbnailSize.width, height: item.thumbnailSize.height, alignment: .center)
        }
    }
    
    
    /**
     *  TITLE VIEW
     */
    func TitleView() -> some View {
        Group {
            if let item = self.selectedItem {
                VStack(spacing:0) {
                    Text( item.title )
                        .font(.system(.headline).weight(.semibold))
                        .truncationMode(.tail)
                        .padding(EdgeInsets(top: 0,leading: 10,bottom: 0,trailing: 10))
                        .foregroundColor(.blue)
                        .fixedSize(horizontal: false, vertical: false)
                        .lineLimit(1)
                    Divider()
                    Text( "\(item.updated)")
                        .font(.system(.subheadline))
                        .foregroundColor(.purple)
                    
                }
                

            }
            else {
                EmptyView()
            }
        }
    }
    
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
    
    /**
     *  CARD VIEW
     */
    func CardView( item: SlidehareItem, onFocusChange: @escaping (SlidehareItem, Bool) -> Void  ) -> some View {
            Button( action: {
                self.downloadManager.download(item: item)  { isItemDownloaded = $0 }
            }) {
          
                ThumbnailView( item: item, onFocusChange: onFocusChange)
                .if( self.downloadManager.isDownloading(item: item) ) {
                    $0.overlay( DownloadProgressView(), alignment: .bottom )
                }
                .padding()
                .frame( width: Const.cardSize.width, height: Const.cardSize.height)
                .background(Color.white)
            }
            .buttonStyle( CardButtonStyle() ) // 'CardButtonStyle' doesn't work whether .focusable() is called
            .disabled( self.downloadManager.isDownloading(item: item) )

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
        NavigationView {
            
            ZStack {
                NavigationLink(destination: PresentationView().environmentObject(downloadManager),
                               isActive: $isItemDownloaded) { EmptyView() }
                    .hidden()
                VStack {
                    SearchBar( text: $slidesResult.searchText ) {
                        
                        ScrollView {
                                LazyVGrid( columns: columns ) {
                                    
                                    ForEach(slidesResult.data, id: \.id) { item in
                                        
                                        CardView( item: item, onFocusChange: setItem )
                                            
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

                    }
                    Spacer()
                    TitleView()
                        
                        
                }
                .edgesIgnoringSafeArea(.bottom)
            }
                
        }.main( gradient: Gradient(colors: [.black, .white]) )
    }
        
}

struct SearchSlides_Previews: PreviewProvider {
    static var previews: some View {
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
}

