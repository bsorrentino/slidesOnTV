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
    func main( gradient:Gradient = Gradient(colors: [.purple, .white]) ) -> some View {
        self.modifier(ScreenModifier(gradient:gradient))
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
        .main()
    }
}
