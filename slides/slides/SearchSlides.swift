//
//  SearchSlides.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 02/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchSlidesView: View {
    @StateObject var slidesResult = SlideShareResult()
    @StateObject var downloadManager = DownloadManager()
    
    let columns = [
            GridItem(.fixed(550)),
            GridItem(.fixed(550)),
            GridItem(.fixed(550)),
        ]

    func Thumbnail(for item: SlidehareItem) -> some View {
        
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
        .frame(width: item.thumbnailSize.width, height: item.thumbnailSize.height, alignment: .center)

    }
    
    func Title( _ text:String ) -> some View {
        Text( text )
            .font(.system(size: 20).italic().weight(.light))
            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(4)
            .frame( maxWidth: 300 )
            .padding()
    }
    
    var NextPage: some View {
        Group {
            if slidesResult.hasMoreItems {
                Button( action: { slidesResult.nextPage() }) {
                    Label( "More Result ...", systemImage: "arrow.right.doc.on.clipboard" )
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                }.buttonStyle(CardButtonStyle())
            }
            else {
                EmptyView()
            }
        }
            
    }
    
    
    var body: some View {
        NavigationView {
            
            ZStack {
                NavigationLink(destination: PresentationView().environmentObject(downloadManager),
                               isActive: $downloadManager.downloadedItem) { EmptyView() }
                    .hidden()
                
                SearchBar( text: $slidesResult.searchText ) {
                    
                    ScrollView {
                        VStack {
                            LazyVGrid( columns: columns) {
                                
                                ForEach(slidesResult.data, id: \.id) { item in
                                    
                                    Button( action: {
                                        self.downloadManager.downloadInfo = item.downloadUrl
                                    }) {
                                        HStack( alignment:.center, spacing: 5 ) {
                                            Thumbnail( for: item )
                                            Divider()
                                            Title( "\(item.title)")
                                        }
                                        .padding()
                                        .background(Color.white)
                                    }
                                    .buttonStyle(CardButtonStyle())
                                }
                                NextPage
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                }
                
            }
        }
        
    }
}

struct SearchSlides_Previews: PreviewProvider {
    static var previews: some View {
        SearchSlidesView()
    }
}

