//
//  SearchSlides.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 02/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

struct SearchSlides: View {
    @State var searchText:String = ""
    
    var body: some View {
        
        
        SearchBar( text: $searchText ) {
            VStack {
                Text("Hello, world!")
                    .padding()
                Button( "test", action: {} )
            }
        }
    }
}

struct SearchSlides_Previews: PreviewProvider {
    static var previews: some View {
        SearchSlides()
    }
}

