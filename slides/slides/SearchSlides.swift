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
            GridItem(.adaptive(minimum: 80))
        ]

    var body: some View {
        
        SearchBar( text: $slidesResult.searchText ) {
            
            ScrollView {
                LazyVGrid( columns: columns) {

                    ForEach(slidesResult.data, id: \.id) { item in
                        Text( item.id )
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

