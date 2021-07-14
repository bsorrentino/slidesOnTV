//
//  PresentationView.swift
//  slides
//
//  Created by softphone on 13/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

struct PresentationView: View {
    
    @EnvironmentObject var downloadInfo:DownloadManager
    
    var body: some View {
        
        Group {
            
            if let doc = downloadInfo.document {
                PDFReaderContentView( document: doc )
            }
            else {
                Text( "error loading presentation")
            }
        }
        
    }
}

//struct PresentationView_Previews: PreviewProvider {
//    static var previews: some View {
//        PresentationView()
//    }
//}
