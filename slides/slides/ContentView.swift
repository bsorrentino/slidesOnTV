    //
//  ContentView.swift
//  slides
//
//  Created by softphone on 01/03/2020.
//  Copyright © 2020 bsorrentino. All rights reserved.
//

import SwiftUI


func NavigationButton<Destination :View>( text:String, image:String, destination: () -> Destination ) -> some View {
    NavigationLink( destination: destination ) {
            HStack {
                Image(systemName: image)
                Text(text)
            }
            .font(.title3)
            .padding(30.0)
    }
    .buttonStyle(CardButtonStyle())

}

struct ContentView: View {
    @State var searchText:String = ""

    
    var BackgroundImage:some View {
        Image("tv-menu").resizable().frame( maxWidth: 1048)
    }
    
    var body: some View {
        NavigationView {
               
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                Spacer()
                VStack(alignment: .center, spacing:50) {
                    Spacer()

                    NavigationButton( text: "Search   ",
                                      image: "magnifyingglass.circle.fill" )
                    {
                        SearchSlidesView()
                    }
                    NavigationButton( text: "Favorites",
                                      image:"bookmark.fill" )
                    {
                        FavoritesView()
                    }
                    Spacer()
                }
                Spacer()
            }
            .background(BackgroundImage)
            
        }
        .mainTheme()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
