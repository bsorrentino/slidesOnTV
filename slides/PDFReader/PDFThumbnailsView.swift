//
//  PDFThumbnailView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 01/11/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI


struct ThumbnailShadow: ViewModifier {
    
    var focused:Bool
    
    func body(content: Content) -> some View {
        if (focused) {
            return content
                .shadow( color: Color.black, radius: 20, x:5, y:5 )
        }
        
        return content.shadow( color: Color.clear, radius: 0 )
    }
}

struct ThumbnailView : View {
    //    @Environment(\.isFocused) var focused: Bool
    
    var uiImage:UIImage
    var size:CGSize
    
    var body: some View {
        
        Image( uiImage: uiImage )
            .resizable()
            .frame(width: size.width,
                   height: size.height,
                   alignment: .center)
    }
}

func pageNumberLabel( of pageNumber:Int ) -> some View {
    
    Circle()
        .fill( Color.blue )
        .shadow( color: Color.black, radius: 1, x:1, y:1)
        .shadow( color: Color.black, radius: 1, x:1, y:1)
        .frame(width: 30, height: 30)
        .padding( EdgeInsets(top:0,leading:0,bottom:5,trailing:5))
        .overlay(
            Text("\(pageNumber)")
                .padding( EdgeInsets(top:0,leading:0,bottom:5,trailing:5) )
                .font(.system(size: 12).weight(.heavy))
        )
}

struct PDFThumbnailsView : View {
    
    var document:PDFDocument
    @Binding var pageSelected: Int
    var parentSize:CGSize
    
    var body: some View {
        
        List( document.allPageNumbers, id: \.self ) { pageNumber in
            
            ThumbnailView( uiImage:document.pdfPageImage(at: pageNumber)!,
                           size:CGSize(width: parentSize.width * 0.2, height: parentSize.height * 0.25))
                .modifier( ThumbnailShadow( focused: pageSelected == pageNumber ) )
                .overlay( pageNumberLabel(of: pageNumber ), alignment: .bottomTrailing )
                .focusable(true) { focused in
                    print( "thumbnail focus on page \(pageNumber) - focused:\(focused)")
                    if( focused && pageNumber != self.pageSelected ) {
                        self.pageSelected = pageNumber
                    }
                }
//              .if( pageNumber == pageSelected ) {
//                  $0.prefersDefaultFocus(in: focusNS )
//              }
        }
        

    }
}

struct PDFThumbnailsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("PDFThumbnailsView")
    }
}
