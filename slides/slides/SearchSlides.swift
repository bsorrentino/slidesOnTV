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
    
    ProgressView: (fill:Color.white.opacity(0.5),  radius:CGFloat(10))
)

struct SearchSlidesView: View {
    @StateObject var slidesResult       = SlideShareResult()
    @StateObject var downloadManager    = DownloadManager()
    
    @State var isItemDownloaded:Bool    = false
    @State var title:String             = ""
    
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
    
    func ThumbnailView(for item: SlidehareItem) -> some View {
        
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
        //.frame(width: item.thumbnailSize.width, height: item.thumbnailSize.height, alignment: .center)

    }
    
    
    /**
     *  TITLE VIEW
     */
    func TitleView() -> some View {
        Text( title )
            .font(.system(size: 20).italic().weight(.light))
            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(4)
            //.frame( maxWidth: 300 )
            .padding()
            .ignoresSafeArea()
    }
    
    /**
     *  NEXT PAGE VIEW
     */
    var NextPageView: some View {
        Group {
            if slidesResult.hasMoreItems {
                Button( action: { slidesResult.nextPage() }) {
                    Label( "More Result ...", systemImage: "arrow.right.doc.on.clipboard" )
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                }
                .buttonStyle( CardButtonStyle() )
            }
            else {
                EmptyView()
            }
        }
            
    }
    
    
    /**
     *  CARD VIEW
     */
    func CardView( item: SlidehareItem ) -> some View {
            Button( action: {
                self.downloadManager.download(item: item)  { isItemDownloaded = $0 }
            }) {
          
                ThumbnailView( for: item )
                .if( self.downloadManager.isDownloading(item: item) ) {
                    $0.overlay( DownloadProgressView(), alignment: .bottom )
                }
                .padding()
                    .frame( width: Const.cardSize.width, height: Const.cardSize.height)
                .background(Color.white)
            }
            .buttonStyle( CardButtonStyle() )
            .disabled( self.downloadManager.isDownloading(item: item) )

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
                                        
                                        CardView( item: item )
                                            
                                    }
                                    
                                    NextPageView
                                }
                        }
                        .padding(.horizontal)

                    }
                    TitleView()
                }
                
            }
                
        }
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

