//
//  SearchSlides.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 02/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

struct SearchSlidesView: View {
    @StateObject var slidesResult = SlideShareResult()
    
    let columns = [
            GridItem(.fixed(550)),
            GridItem(.fixed(550)),
            GridItem(.fixed(550)),
        ]

    var body: some View {
        
        SearchBar( text: $slidesResult.searchText ) {
            
            ScrollView {
                LazyVGrid( columns: columns) {

                    ForEach(slidesResult.data, id: \.id) { item in
                        Button( action: {} ) {
                            Text( "\(item.id)")
                                .padding(150.0)
                            
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

