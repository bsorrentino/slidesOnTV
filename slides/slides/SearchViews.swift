//
//  SearchView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 07/11/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI
   

fileprivate let Const = (
    
    cardSize:       CGSize( width: 490, height: 300 ),
    
    ProgressView: (fill:Color.white.opacity(0.5),  radius:CGFloat(10))
    
)


private struct SearchResultImageView<T> : View where T : SlideItem {
    @Environment(\.isFocused) var focused: Bool
    
    var item: T
    var onFocusChange: (T,Bool) -> Void = { _,_ in }

    private var placeholderView:some View {
        Rectangle().foregroundColor(.gray)
    }
    
    private var imageLoadError:Bool {
        item.thumbnail == nil || WebImageId > 0
    }
    
    private var url:URL? {
        guard let thumbnail = item.thumbnail, WebImageId == 0  else {
            return URL.fromXCAsset(name: "slideshow" )
        }
        return URL(string: thumbnail)
    }
    
    @State private var WebImageId = 0
    
    var body: some View {
    
        Group {
            if( isInPreviewMode ) {
                Image("slideshow")
                    .resizable()
                    .scaledToFit()
            }
            else {
                VStack {
                    AsyncImage( url: url ) { phase in
                        switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                Image(systemName: "photo")
                            @unknown default:
                                // Since the AsyncImagePhase enum isn't frozen,
                                // we need to add this currently unused fallback
                                // to handle any new cases that might be added
                                // in the future:
                                EmptyView()
                        }
                    }
                    .id( WebImageId )
                    if( imageLoadError ) {
                        Divider()
                        Text( "\(item.title)" )
                            .foregroundColor(Color.black)
                    }
                }
            }
        }
        .onChange(of: focused, perform: {
            print( "ThumbnailView(\(item.title)): old:\(focused) new:\($0)")
            onFocusChange( item, $0 ) // Workaround for 'CardButtonStyle' bug
        })
//      .frame(width: item.thumbnailSize.width, height: item.thumbnailSize.height, alignment: .center)
        
    }
}


struct SearchCardView<T> : View where T : SlideItem {
    
    @EnvironmentObject var downloadManager:DownloadManager<T>
    var item: T
    var onFocusChange: (T, Bool) -> Void
    
    var body: some View {
              
        SearchResultImageView( item: item, onFocusChange: onFocusChange)
            .if( self.downloadManager.isDownloading(item: item) ) {
                $0.overlay( DownloadProgressView(), alignment: .bottom )
            }
            .padding()
            .frame( width: Const.cardSize.width, height: Const.cardSize.height)
            .background(Color.white)
    }

    func DownloadProgressView() -> some View {
        
        ZStack {
            Rectangle()
                .fill( Const.ProgressView.fill )
                .cornerRadius(Const.ProgressView.radius)
                .shadow( color: Color.black, radius: Const.ProgressView.radius )

            ProgressView( "Download: \(self.downloadManager.downloadingDescription)", value: self.downloadManager.downloadProgress.0, total:1)
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
                if let updated = item.updated {
                    Divider()
                    Text( "\(updated)")
                        .font(.system(.subheadline))
                        .foregroundColor(.purple)
                }
            }
        }
        else {
            EmptyView()
        }
    }
}
