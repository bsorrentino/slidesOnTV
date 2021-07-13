//
//  ContentView.swift
//  Samples
//
//  Created by softphone on 01/03/2020.
//  Copyright © 2020 mytrus. All rights reserved.
//
import SwiftUI


struct PDFThumbnailView : View {
    
    var document:PDFDocument
    
    @Binding var pageSelected:Int
    
    var thumbnailSize:CGSize
    
    func thumbnailView( pageNumber:Int ) -> some View {
        Button( action: {} ) {
            
            Image( uiImage: self.document.pdfPageImage(at: pageNumber)! )
                    .resizable()
                    .frame(width: self.thumbnailSize.width,
                           height: self.thumbnailSize.height,
                           alignment: .center)
                .overlay(
                    Text( "page \(pageNumber)" )
                        .font(.footnote.italic().weight(.thin))
                        .foregroundColor(.gray)
                        .padding(),
                    alignment: .bottomTrailing )
            //.background(Color.white)
            //.padding()
        }
        .buttonStyle(CardButtonStyle())
        .focusable(true) { changed in
            if( changed ) {
                self.pageSelected = pageNumber
            }
        }

    }
    
    var body: some View {
        ScrollView(showsIndicators: false ) {
            
            VStack(alignment: .leading) {
                    
                ForEach( document.allPageNumbers, id: \.self,  content:thumbnailView )
            }
        }
        
    }
}


struct PDFReaderContentView: View {
    
    var document:PDFDocument
    
    @State var pageSelected: Int = 1
    
    var body: some View {
        GeometryReader { geom in
            HStack {
                
                PDFThumbnailView( document:self.document,
                                  pageSelected:self.$pageSelected,
                                  thumbnailSize:CGSize(width: 300, height: geom.size.height/2))
                    .frame( height: geom.size.height - 1)
                
                if self.pageSelected > 0  {
                    Spacer()
                    
                    PDFDocumentView(
                        document:self.document,
                        pageSelected:self.$pageSelected )
                        
                    
//                    Text( """
//                            geom:
//                                h:\(geom.size.height)
//                                w:\(geom.size.width)
//                          """)
//                        .foregroundColor(.black)
                    Spacer()
                }
                
                
            }.background(Color.gray)
        }
    }
}


struct PDFReaderContentView_Previews: PreviewProvider {
    static var previews: some View {
        PDFReaderContentView(document: PDFDocument.createFormBundle(resource: "apple"))
    }
}
