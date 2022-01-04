//
//  PresentationView.swift
//  slides
//
//  Created by softphone on 13/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI
import TVOSToast

struct PresentationView<T>: View where T : SlideItem {
    
    @EnvironmentObject var downloadInfo:DownloadManager<T>
    @State var isZoom = false
    @State var pageSelected: Int = 1

    
    func saveToFavorites() {
        
        if let item = downloadInfo.downdloadedItem {
            NSUbiquitousKeyValueStore.default.favoriteAdd(data: item, synchronize: true)
            showToast_Bookmark_Saved()
        }
    }
    
    
    func ToolbarModifierForFavorite<Content:View>( _ content: Content) -> some View {
        
        content
        .navigationTitle("")
        .toolbar {
            
            ToolbarItem(placement: .primaryAction) {
                Button( action: { isZoom.toggle() } ) {
                                Image( systemName: "arrow.up.left.and.arrow.down.right")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .frame(width: 25.0, height: 25.0)
                                    //.padding( .top, 40 )
                            }
            }
                
        }

    }

    func ToolbarModifierForSlide<Content:View>( _ content: Content) -> some View {
        
        content
        .navigationTitle("")
        .toolbar {
            
            ToolbarItem(placement: .primaryAction) {
                Button( action: { isZoom.toggle() } ) {
                                Image( systemName: "arrow.up.left.and.arrow.down.right")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .frame(width: 25.0, height: 25.0)
                                    //.padding( .top, 40 )
                            }
            }
                
            ToolbarItem(placement: .confirmationAction) {
                Button( action: saveToFavorites ) { //
                    Image( systemName: "bookmark")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .frame(width: 25, height: 25)
                        //.padding( .top, 40 )
                }
            }
        }

    }
    
    private func ToolbarModifier<Content:View>( _ content: Content) -> some View {
        
        Group {
            if downloadInfo.downdloadedItem is FavoriteItem {
                ToolbarModifierForFavorite( content )
            }
            else {
                ToolbarModifierForSlide( content )
            }
        }
    }
    
    var body: some View {
        NavigationView {
            if let doc = downloadInfo.downloadedDocument {
                PDFReaderContentView( document: doc, pageSelected: $pageSelected, isZoom: isZoom )
                    .if( isZoom ) { $0.onExitCommand { isZoom.toggle() } }
                    .if( !isZoom , modifier: ToolbarModifier )
                    .if( isZoom ) { $0.edgesIgnoringSafeArea( .all ) }
                    .if( isZoom ) { $0.onAppear(perform: showToast_How_To_Navigate_Slides) }
            }
            else {
                Text( "error loading presentation")
            }
        }

    }
}

// MARK: PresentationView Toast Extension

extension PresentationView {
    
    private func showToast_Bookmark_Saved() {
        
        guard let viewController = UIApplication.shared.windows.first!.rootViewController,
              let image = UIImage(systemName: "bookmark.circle.fill") else {return}
        
            let style = TVOSToastStyle( position: .bottomRight(insets: 10) )
            let toast = TVOSToast(frame: CGRect(x: 0, y: 0, width: 800, height: 80),
                                  style: style)
            
            toast.hintText =
                TVOSToastHintText(element:
                    [.imageType(image),
                     .stringType(" Bookmark Saved! ")])
            
            viewController.presentToast(toast)
    }

    private func showToast_How_To_Navigate_Slides() {
        
        guard let viewController = UIApplication.shared.windows.first!.rootViewController,
              let imageL = UIImage(named: "remoteTouchLalpha",
                                  in: Bundle.main,
                                  compatibleWith: nil),
              let imageR = UIImage(named: "remoteTouchRalpha",
                                    in: Bundle.main,
                                    compatibleWith: nil) else { return }
        
        let style = TVOSToastStyle( position: .topRight(insets: 10), backgroundColor: .link, textColor: .white )
            let toast = TVOSToast(frame: CGRect(x: 0, y: 0, width: 800, height: 80),
                                  style: style)
            
            toast.hintText =
                TVOSToastHintText(element:
                    [.stringType("Tap left "),
                     .imageType(imageL),
                     .stringType(" and right "),
                     .imageType(imageR),
                     .stringType(" to navigates slides")])
            
            viewController.presentToast(toast)
    }

    

}

//struct PresentationView_Previews: PreviewProvider {
//    static var previews: some View {
//        PresentationView()
//    }
//}
