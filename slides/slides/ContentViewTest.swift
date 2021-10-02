//
//  PresentationViewTest.swift
//  slides
//
//  Created by softphone on 02/10/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

struct CommandBar : View {
    
    @Binding var isZoom:Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Spacer()
            
            Button( action: { isZoom.toggle() } ) {
                Image( systemName: "arrow.up.left.and.arrow.down.right")
                    //.resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    //.frame(width: 16.0, height: 16.0)
            }
            //.buttonStyle(CardButtonStyle())
        }
        
    }
}

struct ContentViewTest: View {
    @Namespace var focusContext
    
    var body: some View {
        
        ZStack {
        
            HStack {
                Spacer()
                Text( "TEST" )
                
                Button( action: {} ) {
                    Text( "TEST" )
                }
                .prefersDefaultFocus(in: focusContext)

                
                Text( "TEST" )
                
                Spacer()
            }
            //.background( Color.gray )
            //.edgesIgnoringSafeArea( .trailing )
            //.edgesIgnoringSafeArea( .leading )
            //.edgesIgnoringSafeArea( .bottom )
            
            VStack {
                Spacer()
                HStack(alignment: .center, spacing: 100 ) {
                    Button( action: {} ) {
                        Image( systemName: "arrow.up.left.and.arrow.down.right")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .frame(width: 25.0, height: 25.0)
                            .padding( .top, 40 )
                    }
                    .frame( width: 50, height: 50)
                    Button( action: {} ) { //
                        Image( systemName: "bookmark")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .frame(width: 25, height: 25)
                            .padding( .top, 40 )
                    }
                    .frame( width: 50, height: 50)
                    
                }
            }.ignoresSafeArea()
            

        }
        .focusScope( focusContext )
        .background( Color.blue )
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }
}

struct ContentViewTest_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewTest()
    }
}
