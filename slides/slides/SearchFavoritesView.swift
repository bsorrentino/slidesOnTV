//
//  FavoritesView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 07/11/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI
import Combine
import TVOSToast

fileprivate let Const = (
    gridItemSize:   CGFloat(500),
    
    Background: Color.blue
)


struct FavoriteContextMenuModifier: ViewModifier {
    
    var item : FavoriteItem
    var delete: ( FavoriteItem ) -> Void
    var download: ( FavoriteItem ) async -> Void
    @State private var confirmationDelete = false
    @State private var confirmationDeleteAll = false

    func body(content: Content) -> some View {
        content
            .contextMenu {
//                Button( "MENU") { }
                Button( "Download") {
                    Task { await download(item) }
                }
                Button( "Delete", role: .destructive ) {
                    confirmationDelete.toggle()
                }
                
            }
            .confirmationDialog(
                String("Are you sure?"),
                isPresented: $confirmationDelete
            ) {
                Button("Yes") {
                    withAnimation {
                        delete(item)
                    }
                }
            }
    }
}

struct FavoritesView: View {
    
    @StateObject var downloadManager = DownloadManager<FavoriteItem>()
    @State var isItemDownloaded:Bool    = false
    @State var selectedItem:FavoriteItem?
    @State private var data:[FavoriteItem] = []
    
    private let columns:[GridItem] = Array(repeating: .init(.fixed(Const.gridItemSize)), count: 3)
    
    private var cancellable: AnyCancellable?
    
    private func downloadFavorite( _ item : FavoriteItem ) async -> Void {
        isItemDownloaded =  await self.downloadManager.downloadFavorite(item)
    }
    
    private func deleteFavorite( _ item : FavoriteItem ) {
        NSUbiquitousKeyValueStore.default.removeFavorite(key: item.id, synchronize: true)
        selectedItem = nil
        data = NSUbiquitousKeyValueStore.default.favorites()
    }

    var body: some View {
        NavigationStack {
            VStack {
                
                HStack(alignment: .center, spacing: 10 ) {
                    Image( systemName: "bookmark.fill")
                        .resizable()
                        .scaledToFit()
                        .frame( minWidth: 100, maxHeight: 70 )
                    
                    Text( "Favorites" )
                        .font(.largeTitle.bold())
                    
                }.padding()
                Divider()
                //
                // @ref https://stackoverflow.com/a/67730429/521197
                //
                // ScrollViewReader usage for dynamically scroll to tagged position
                //
                ScrollView {
                    LazyVGrid( columns: columns ) {
                        
                        ForEach(data, id: \.id) { item in
                            
                            Button( action: { Task { await downloadFavorite(item) } } )
                            {
                                SearchCardView<FavoriteItem>( item: item,
                                                              onFocusChange: setItem )
                                    .environmentObject(downloadManager)
                            }
                            .buttonStyle( CardButtonStyle() ) // 'CardButtonStyle' doesn't work whether .focusable() is called
                            .disabled( self.downloadManager.isDownloading(item: item) )
                            .id( item.id )
                            .modifier( FavoriteContextMenuModifier(item: item, 
                                                                   delete: deleteFavorite,
                                                                   download: downloadFavorite ) )                            
                        }
                    }
                    
                }
                .padding(.horizontal)
                
                Spacer()
                TitleView( selectedItem: selectedItem )
            }
            .onAppear {
                data = NSUbiquitousKeyValueStore.default.favorites()
                showToast_How_To_Open_Menu()
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationDestination(isPresented: $isItemDownloaded ) {
                PresentationView<FavoriteItem>()
                    .environmentObject(downloadManager)
            }
        }
        .favoritesTheme()
    }
    
    
    fileprivate func resetItem( OnFocusChange focused : Bool ) {
        if focused {
            self.selectedItem = nil
        }
    }
    
    fileprivate func setItem( item:FavoriteItem, OnFocusChange focused : Bool ) {
        if focused {
            self.selectedItem = item
        }
        else if( item == self.selectedItem ) {
            self.selectedItem = nil
        }
    }
    
}

// MARK: FavoriteView Toast Extension

extension FavoritesView {
    
    private func showToast_How_To_Open_Menu() {
        
        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            log.error( "rootViewController not found!")
            return
        }
        
        let style = TVOSToastStyle( position: .topRight(insets: 10), duration: 3.5, backgroundColor: UIColor.link )
        let toast = TVOSToast(frame: CGRect(x: 0, y: 0, width: 600, height: 80),
                              style: style)
        
        toast.hintText =
        TVOSToastHintText(element:
                            [.stringType("'Long press' to open menu")])
        
        viewController.presentToast(toast)
    }
}

// MARK: - Download Manager Extension

extension DownloadManager where T == FavoriteItem {
    
    func downloadFavorite( _ item: FavoriteItem ) async -> Bool {
        
        return await withCheckedContinuation { (continuation ) in
            
            guard let credentials = try? SlideshareApi.getCredential() else {
                log.debug("failed getting credential")
                continuation.resume(returning: false)
                return
            }
            
            let api = SlideshareApi()
            
            let parser = SlideshareItemsParser()
            
            guard let query = try? api.queryById(credentials: credentials, id: item.id ) else {
                log.error( "error invoking slideshare API" )
                continuation.resume(returning: false)
                return
            }
            
            let onCompletion = { (completion:Subscribers.Completion<Error>) in
                switch completion {
                case .failure(let error):
                    log.error( "\(error.localizedDescription)")
                    continuation.resume(returning: false)
                case .finished:
                    log.debug("DONE!")
                }
            }
            
            query.toGenericError()
                .flatMap    { parser.parse($0.data) }
                .map        { SlidehareItem(data:$0) }
                .compactMap { FavoriteItem(item:$0) }
                .first()
            //.receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: onCompletion,
                    receiveValue: { favoriteItem in
                        // self.download(item: $0, completionHandler: completionHandler)
                        Task {
                            let status = await self.download(item: favoriteItem)
                            log.debug("Download finished: status \(status)")
                            continuation.resume(returning: status)
                        }
                    })
                .store(in: &bag)
            
        }
    }
}


#Preview {
    FavoritesView()
}
