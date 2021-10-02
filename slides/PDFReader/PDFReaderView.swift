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



struct PDFReaderContentView: View {
    @Namespace private var focusNS
    
    var document:PDFDocument
    
    @State var pageSelected: Int = 1
    @State var isPointerVisible: Bool = false
    @State var isZoom = false
    
    var CommandBar: some View {
        
        VStack {
            Spacer()
            HStack(alignment: .center, spacing: 100 ) {
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
                Button( action: { isZoom.toggle() } ) {
                    Image( systemName: "arrow.up.left.and.arrow.down.right")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .frame(width: 25.0, height: 25.0)
                        .padding( .top, 40 )
                }
                .frame( width: 50, height: 50)

            }
        }.ignoresSafeArea()
    }
    
    var body: some View {
        
        GeometryReader { geom in
            ZStack {
                
                HStack {
                    
                    if( !isZoom ) {
                        
                        List( document.allPageNumbers, id: \.self ) { pageNumber in
                            
                            ThumbnailView( uiImage:document.pdfPageImage(at: pageNumber)!,
                                           size:CGSize(width: geom.size.width * 0.2, height: geom.size.height * 0.25))
                                .modifier( ThumbnailShadow( focused: pageSelected == pageNumber ) )
                                .overlay( pageNumberLabel(of: pageNumber ), alignment: .bottomTrailing )
                                .focusable(true) { focused in
                                    print( "thumbnail focus on page \(pageNumber) - focused:\(focused) - pinter:\(isPointerVisible)")
                                    if( focused && pageNumber != self.pageSelected ) {
                                        self.pageSelected = pageNumber
                                    }
                                }
                        }
                        .frame( width: geom.size.width * 0.2, height: geom.size.height - 1)
                        //  .focusable( isPointerVisible ) { focused in
                        //      print( "thumbnail List focus on page \(pageSelected) - focused:\(focused pointer:\(isPointerVisible)")
                        //   }
                        .prefersDefaultFocus(in: focusNS )
                    }
                    if self.pageSelected > 0  {
                        
                        Group {
                            if( !isZoom ) { Spacer() }
                            
                            PDFDocumentView(
                                document:self.document,
                                pageSelected:self.pageSelected,
                                isPointerVisible:self.$isPointerVisible)

                            if( !isZoom ) { Spacer() }
                        }
                        .if( isZoom , transform: { view in view.edgesIgnoringSafeArea( .all ) } )

                    }
                }
                
                CommandBar
            }
            .focusScope( focusNS )
            .background(Color.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        
    }
    
}

struct PDFReaderContentView_Previews: PreviewProvider {
    static var previews: some View {
        zstack_previews
    }
    
    static var zstack_previews: some View {
        // PDFReaderContentView(document: PDFDocument.createFormBundle(resource: "apple"))
        GeometryReader { geom in
            ZStack {
                
                HStack {
                    Spacer()
                    Text( "TEST" )
                    Button( action:{} ) {  Text("TEST") }
                    Text( "TEST" )
                    
                    Spacer()
                }
                .frame(height: 500)
                .background( Color.blue )
                
                VStack {
                HStack {
                    Spacer()
                    Button( action: {} ) {
                        Image( systemName: "arrow.up.left.and.arrow.down.right")
                        //.resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                        //.frame(width: 16.0, height: 16.0)
                    }
                }
                .padding( EdgeInsets( top:15, leading: 0,bottom: 0, trailing: 20 ))
                Spacer()
                }
                //.frame( width: geom.size.width, height: 10, alignment: .top )
                //.background( Color.red )

                //.edgesIgnoringSafeArea(.all)
            }
            .frame(width: geom.size.width, height: geom.size.height, alignment: .topTrailing)
            .background( Color.gray )
            //.edgesIgnoringSafeArea(.all)
        }
    }
    
//    static var overlay_previews: some View {
//        // PDFReaderContentView(document: PDFDocument.createFormBundle(resource: "apple"))
//        VStack {
//
//            HStack {
//                Spacer()
//                Text( "TEST" )
//                Text( "TEST" )
//
//                Spacer()
//            }
//            .frame(height: 500)
//            .background( Color.blue )
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background( Color.gray )
//        .edgesIgnoringSafeArea( .trailing )
//        .edgesIgnoringSafeArea( .leading )
//        .edgesIgnoringSafeArea( .bottom )
//        .overlay(
//            PDFReaderContentView.CommandBar( isZoom: .constant(false))
//                .padding( EdgeInsets( top:15, leading: 0,bottom: 0, trailing: 20 )) ,
//            alignment: .top )
//    }

    static var shadow_previews: some View {
        // PDFReaderContentView(document: PDFDocument.createFormBundle(resource: "apple"))
        VStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
                .shadow( color:Color.black, radius: 1, x:2, y:1)
                .shadow( color:Color.black, radius: 1, x:2, y:1)
                .overlay(
                    Text("2")
                        .padding()
                        .font(.system(size: 10).weight(.medium))
                )
            Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
                .overlay(
                    Text("20")
                        .padding()
                        .font(.system(size: 10).weight(.medium))
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background( Color.white )
        //.edgesIgnoringSafeArea(.all)
    }

}
