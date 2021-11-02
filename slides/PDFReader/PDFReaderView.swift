//
//  ContentView.swift
//  Samples
//
//  Created by softphone on 01/03/2020.
//  Copyright © 2020 mytrus. All rights reserved.
//
import SwiftUI


struct PDFReaderContentView: View {
    @Namespace private var focusNS
    @State var isPointerVisible: Bool = false

    var document:PDFDocument
    @Binding var pageSelected: Int
    var isZoom: Bool
        
    
    var CurrentPageView:some View {
        PDFDocumentView(
            document:           self.document,
            page:               self.pageSelected,
            isPointerVisible:   self.$isPointerVisible)
    }
    
    var body: some View {
        
        Group {
            if isZoom {
                CurrentPageView
            }
            else {
                
                GeometryReader { geom in
                    HStack {
                        //PDFThumbnailsView( 
                        PDFThumbnailsViewUIKit(
                            document:       document,
                            pageSelected:   $pageSelected,
                            parentSize:     geom.size )
                        .equatable()
                        .frame( width: geom.size.width * 0.2, height: geom.size.height - 1)
                        .prefersDefaultFocus( in: focusNS )

                        Spacer()
                        CurrentPageView
                        Spacer()
                    }
                    .focusScope( focusNS )
                }
            }
        }
        .background(Color.gray)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

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


}
