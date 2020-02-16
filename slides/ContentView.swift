//
//  ContentView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 16/02/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
 
    var body: some View {
        NavigationView {
            Text("First View")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
