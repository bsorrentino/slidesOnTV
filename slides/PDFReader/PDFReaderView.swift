//
//  ContentView.swift
//  Samples
//
//  Created by softphone on 01/03/2020.
//  Copyright © 2020 mytrus. All rights reserved.
//
import SwiftUI

struct ThumbnailShadow: ViewModifier {
    
    var focused:Bool
    
    func body(content: Content) -> some View {
        (focused) ?
            content.shadow( color: Color.black, radius: 10, x:5, y:5 ) :
            content.shadow( color: Color.clear, radius: 0 )
        
//        page.layer.masksToBounds = false
//        page.layer.shadowColor = UIColor.black.cgColor
//        page.layer.shadowOpacity = 1
//        page.layer.shadowOffset = CGSize(width: 0 , height: height)
//        page.layer.shadowRadius = 10
//        page.layer.cornerRadius = 0.0
    }
}

struct ThumbnailView : View {
//    @Environment(\.isFocused) var focused: Bool

    var uiImage:UIImage
    var pageNumber:Int
    var thumbnailSize:CGSize
    
    @State var focused = false
    
    var body: some View {
        
        Image( uiImage: uiImage )
            .resizable()
            .frame(width: thumbnailSize.width,
                   height: thumbnailSize.height,
                   alignment: .center)
            .overlay(
                Text( "page \(pageNumber)" )
                    .font(.footnote.italic().weight(.thin))
                    .foregroundColor(.gray)
                    .padding(),
                alignment: .bottomTrailing )

    }
}


struct PDFReaderContentView: View {
    
    var document:PDFDocument
    
    @State var pageSelected: Int = 1
    @State var isPointerVisible: Bool = false
    @State var pageWithFocus:Int = 1
    
    var body: some View {
        GeometryReader { geom in
            
            HStack {
                
                List( document.allPageNumbers, id: \.self ) { pageNumber in
                    
                    ThumbnailView( uiImage:document.pdfPageImage(at: pageNumber)!,
                                   pageNumber:pageNumber,
                                   thumbnailSize:CGSize(width: geom.size.width * 0.2, height: geom.size.height * 0.25))
                        .modifier( ThumbnailShadow( focused: pageWithFocus == pageNumber ) )
                        .focusable(true) { focused in
                            print( "thumbnail focus on page \(pageNumber) - focused:\(focused) - pinter:\(isPointerVisible)")
                            if( focused ) {
                                self.pageSelected = pageNumber
                                self.pageWithFocus = pageNumber
                            }
                            else
                            {
                                self.pageWithFocus = 0
                            }
                        }
                }
                .frame( width: geom.size.width * 0.2, height: geom.size.height - 1)
                .focusable( isPointerVisible ) { focused in
                    print( "thumbnail List focus on page \(pageSelected) - focused:\(focused) -  pointer:\(isPointerVisible)")
                }
                
                if self.pageSelected > 0  {
                    Spacer()
                    
                    PDFDocumentView(
                        document:self.document,
                        pageSelected:self.$pageSelected,
                        isPointerVisible:self.$isPointerVisible)
                    
                    Spacer()
                }
            }
            .background(Color.gray)
        }
            
    }
    
    //                    Text( """
    //                            geom:
    //                                h:\(geom.size.height)
    //                                w:\(geom.size.width)
    //                          """)
    //                        .foregroundColor(.black)

    
}


struct PDFReaderContentView_Previews: PreviewProvider {
    static var previews: some View {
        PDFReaderContentView(document: PDFDocument.createFormBundle(resource: "apple"))
    }
}
