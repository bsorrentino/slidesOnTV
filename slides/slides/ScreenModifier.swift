//
//  ScreenModifier.swift
//  slides
//
//  Created by softphone on 12/08/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

struct ScreenModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        
        return content.background(
                LinearGradient(gradient: Gradient(colors: [.white, .black]), startPoint: .top, endPoint: .bottom))
                .edgesIgnoringSafeArea(.all)
    }
}


extension View {
    func main() -> some View {
        self.modifier(ScreenModifier())
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
