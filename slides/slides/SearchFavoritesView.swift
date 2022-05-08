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
    var download: ( FavoriteItem ) -> Void
    @State private var confirmationShown = false

    #if swift(<15.0)

    @State private var presentSheet = false

    struct MenuButtonModifier: ViewModifier {
        var foreground: Color?
        var background: Color?
        func body(content: Content) -> some View {
            content
                .font(.headline)
                .padding(EdgeInsets( top: 10, leading: 120, bottom: 10, trailing: 120 ))
                .if( foreground != nil ) { $0.foregroundColor( foreground )}
                .if( background != nil ) { $0.background( background )}
        }
    }
    
    private var sheetTitle:some View {
        HStack {
            Label( "Actions", systemImage: "filemenu.and.selection")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
            Text( "_press 'MENU' to dismiss_")
                .font(.callout)
        }
    }
    
    #endif
    
    func body(content: Content) -> some View {
        content
            #if swift(>=15.0)
            .contextMenu {
                    Button( "MENU 􀱢") { }
                    Button( "Download 􀈄") { download(item) }
                    Button( "Delete 􀈓", role: .destructive ) { confirmationShown.toggle() }

            }
            .confirmationDialog(
                "Are you sure?",
                 isPresented: $confirmationShown
            ) {
                Button("Yes") {
                    withAnimation {
                        delete(item)
                    }
                }
            }
            #else
            .onLongPressGesture(minimumDuration: 0.5,
                                perform: { presentSheet.toggle() },
                                onPressingChanged: { state in print("onPressingChanged: \(state)")})
            .sheet(isPresented: $presentSheet) {
                VStack {
                    sheetTitle
                    Divider()
                    Button( action: { presentSheet.toggle(); download(item) },
                            label: { Label( "Download", systemImage: "square.and.arrow.down")
                                        .modifier( MenuButtonModifier( foreground: .black, background: .white) )
                        })
                        .buttonStyle(.plain)
                    Button( action: { confirmationShown.toggle() },
                            label: { Label( "Delete", systemImage: "trash.circle")
                                        .modifier( MenuButtonModifier( foreground: .white, background: .red) )
                        })
                        .buttonStyle(.plain)
                }
                .fixedSize()
                .padding()
                .alert( isPresented: $confirmationShown) {
                    Alert(
                        title: Text("Are you sure you want to delete this?"),
                        message: Text("**There is no undo**"),
                        primaryButton: .destructive(Text("Confirm")) {
                            presentSheet.toggle()
                            delete(item)
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            #endif
    }
}

struct FavoritesView: View {

    @StateObject var downloadManager = DownloadManager<FavoriteItem>()
    @State var isItemDownloaded:Bool    = false
    @State var selectedItem:FavoriteItem?
    @State private var data:[FavoriteItem] = []

    private let columns:[GridItem] = Array(repeating: .init(.fixed(Const.gridItemSize)), count: 3)

    private var cancellable: AnyCancellable?

    private func download( _ item : FavoriteItem ) {
        self.downloadManager.downloadFavorite(item) { isItemDownloaded = $0 }
    }
    private func delete( _ item : FavoriteItem ) {
        NSUbiquitousKeyValueStore.default.favoriteRemove(key: item.id)
        selectedItem = nil
        data = NSUbiquitousKeyValueStore.default.favorites()
    }

    var body: some View {
        NavigationView {

            ZStack {
                NavigationLink(destination: PresentationView<FavoriteItem>()
                                                .environmentObject(downloadManager),
                               isActive: $isItemDownloaded) { EmptyView() }
                               .hidden()
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

                                Button( action: { download(item) } )
                                {
                                    SearchCardView<FavoriteItem>( item: item,
                                                                   onFocusChange: setItem )
                                        .environmentObject(downloadManager)
                                }
                                .buttonStyle( CardButtonStyle() ) // 'CardButtonStyle' doesn't work whether .focusable() is called
                                .disabled( self.downloadManager.isDownloading(item: item) )
                                .id( item.id )
                                .modifier( FavoriteContextMenuModifier(item: item, delete: delete, download: download) )

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
                    
                    DispatchQueue.main.async {
                        let mainUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
                        print( "mainUrl: \(String(describing: mainUrl))" )
                    }
                }

            }
            .edgesIgnoringSafeArea(.bottom)
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
        
        guard let viewController = UIApplication.shared.windows.first!.rootViewController else {return}
        
        let style = TVOSToastStyle( position: .topRight(insets: 10), backgroundColor: UIColor.link )
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

    func downloadFavorite( _ item: FavoriteItem, completionHandler: @escaping (Bool) -> Void ) {

        guard let credentials = try? SlideshareApi.getCredential() else {
            return
        }

        let api = SlideshareApi()

        let parser = SlideshareItemsParser()

        if let query = try? api.queryById(credentials: credentials, id: item.id ) {

            let onCompletion = { (completion:Subscribers.Completion<Error>) in
                switch completion {
                case .failure(let error):
                    log.error( "\(error.localizedDescription)")
                case .finished:
                    log.debug("DONE!")
                }
            }

           query.toGenericError()
                .flatMap    { parser.parse($0.data) }
                .map        { SlidehareItem(data:$0) }
                .compactMap { FavoriteItem(item:$0) }
                .first()
                .sink(
                    receiveCompletion: onCompletion,
                    receiveValue: {
                        self.download(item: $0, completionHandler: completionHandler)
                    })
                .store(in: &bag)
        }
        else {
            log.error( "error invoking slideshare API" )
        }


    }
}


struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
