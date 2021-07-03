    //
//  ContentView.swift
//  slides
//
//  Created by softphone on 01/03/2020.
//  Copyright © 2020 bsorrentino. All rights reserved.
//

import SwiftUI


func MainButton( text:String, image:String, action: @escaping () -> Void ) -> some View {

    Button( action: action ) {
            HStack {
                Image(systemName: image)
                Text(text)
            }
            .font(.title3)
            .padding(30.0)
    }
    .buttonStyle(CardButtonStyle())

}

func NavigationButton<Destination :View>( text:String, image:String, destination: Destination ) -> some View {
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

    
    var Buttons:some View  {
            VStack(alignment: .center, spacing:50) {

                Spacer()
                NavigationButton( text: "Search   ", image: "magnifyingglass.circle.fill", destination:SearchSlidesView() )
                NavigationButton( text: "Favorites", image:"bookmark.fill", destination: Text("TO DO") )
                Spacer()
            }
    }
    
    var BackgroundImage:some View {
        Image("tv-menu").resizable().frame( maxWidth: 1048)
    }
    
    var body: some View {
        NavigationView {
        ZStack {
           
        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            Spacer()
            Buttons
            Spacer()
        }
        .background(BackgroundImage)
        .background(Color.purple.edgesIgnoringSafeArea(.all))
        }
        
    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
