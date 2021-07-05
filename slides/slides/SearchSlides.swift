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
    
    let columns = [
            GridItem(.fixed(550)),
            GridItem(.fixed(550)),
            GridItem(.fixed(550)),
        ]

    func Thumbnail(url:String) -> some View {
        WebImage(url: URL(string: url ) )
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
    
    var body: some View {
        
        SearchBar( text: $slidesResult.searchText ) {
            
            ScrollView {
                LazyVGrid( columns: columns) {

                    ForEach(slidesResult.data, id: \.id) { item in
                        Button( action: {} ) {
                            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 5 ) {
                                Thumbnail( url:item.thumbnailXXL )
                                    .frame(width: 500, height: 400, alignment: .center)
                                Text( "\(item.id)")
                            }
                            .padding()
                            
                        }
                        .buttonStyle(CardButtonStyle())
                        
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct SearchSlides_Previews: PreviewProvider {
    static var previews: some View {
        SearchSlidesView()
    }
}

