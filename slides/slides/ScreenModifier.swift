//
//  ScreenModifier.swift
//  slides
//
//  Created by softphone on 12/08/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

struct ScreenModifier: ViewModifier {
    var gradient:Gradient
    
    
    func body(content: Content) -> some View {
        
        return content.background(
                LinearGradient(gradient:gradient , startPoint: .top, endPoint: .bottom))
                .edgesIgnoringSafeArea(.all)
    }
}


extension View {
    //
    func searchTheme()  -> some View {
        self.modifier( ScreenModifier(gradient: Gradient(colors: [.black, .white])))
    }
    
    func favoritesTheme()  -> some View {
        self.modifier( ScreenModifier(gradient: Gradient(colors: [.purple, .white])))
    }
    
    func mainTheme() -> some View {
        self.modifier(ScreenModifier(gradient:Gradient(colors: [.purple, .white])))
    }
}


struct ScreenModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Test")
                Spacer()
            }
            Spacer()
            
        }
        .mainTheme()
    }
}
