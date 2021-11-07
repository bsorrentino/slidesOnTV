//
//  SearchView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 07/11/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI
   

fileprivate let Const = (
    
    cardSize:       CGSize( width: 490, height: 300 ),
    
    ProgressView: (fill:Color.white.opacity(0.5),  radius:CGFloat(10))
    
)


private struct SearchResultImageView<T> : View where T : SlideItem {
    @Environment(\.isFocused) var focused: Bool
    
    var item: T
    var onFocusChange: (T,Bool) -> Void = { _,_ in }

    var body: some View {
    
        Group {
            if( isInPreviewMode ) {
                Image("slideshow")
                    .resizable()
                    .scaledToFit()
            }
            else {
                WebImage(url: URL(string: item.thumbnail) )
                    // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
                    .onSuccess { image, data, cacheType in
                        // Success
                        // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                        // print( "ThumbnailView: \(focused) - \(item.title)")
                    }
                    .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                    .placeholder(Image(systemName: "photo")) // Placeholder Image
                    // Supports ViewBuilder as well
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .indicator(.activity) // Activity Indicator
                    .transition(.fade(duration: 0.5)) // Fade Transition with duration
                    .scaledToFit()
            }
        }
        .onChange(of: focused, perform: {
            print( "ThumbnailView(\(item.title)): old:\(focused) new:\($0)")
            onFocusChange( item, $0 ) // Workaround for 'CardButtonStyle' bug
        })
//            .frame(width: item.thumbnailSize.width, height: item.thumbnailSize.height, alignment: .center)
    }
}



struct SearchCardView<T> : View where T : SlideItem {
    
    var item: T
    var downloadManager: DownloadManager<T>
    @Binding var isItemDownloaded: Bool
    var onFocusChange: (T, Bool) -> Void
    
    var body: some View {
        
        Button( action: {
            self.downloadManager.download(item: item)  { isItemDownloaded = $0 }
        }) {
      
            SearchResultImageView( item: item, onFocusChange: onFocusChange)
            .if( self.downloadManager.isDownloading(item: item) ) {
                $0.overlay( DownloadProgressView(), alignment: .bottom )
            }
            .padding()
            .frame( width: Const.cardSize.width, height: Const.cardSize.height)
            .background(Color.white)
        }
        .buttonStyle( CardButtonStyle() ) // 'CardButtonStyle' doesn't work whether .focusable() is called
        .disabled( self.downloadManager.isDownloading(item: item) )
    }

    func DownloadProgressView() -> some View {
        
        ZStack {
            Rectangle()
                .fill( Const.ProgressView.fill )
                .cornerRadius(Const.ProgressView.radius)
                .shadow( color: Color.black, radius: Const.ProgressView.radius )

            ProgressView( "Download: \(self.downloadManager.downloadingDescription)", value: self.downloadManager.downloadProgress?.0, total:1)
                .progressViewStyle(BlueShadowProgressViewStyle())
                .padding()
                
        }
    }

}


/**
 *  TITLE VIEW
 */
func TitleView<T>( selectedItem: T?) -> some View where T : SlideItem  {
    Group {
        if let item = selectedItem {
            VStack(spacing:0) {
                Text( item.title )
                    .font(.system(.headline).weight(.semibold))
                    .truncationMode(.tail)
                    .padding(EdgeInsets(top: 0,leading: 10,bottom: 0,trailing: 10))
                    .foregroundColor(.blue)
                    .fixedSize(horizontal: false, vertical: false)
                    .lineLimit(1)
                Divider()
                Text( "\(item.updated)")
                    .font(.system(.subheadline))
                    .foregroundColor(.purple)
                
            }
        }
        else {
            EmptyView()
        }
    }
}
