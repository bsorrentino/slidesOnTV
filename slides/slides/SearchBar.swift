//
//  SearchBar.swift
//  slides
//
//  Created by softphone on 01/07/21.
//
// @ref https://axelhodler.medium.com/creating-a-search-bar-for-swiftui-e216fe8c8c7f
// @ref https://github.com/ageres7-dev/WeatherTV/blob/1b20637c90ffa18b154fb526233f656f6845bc5d/WeatherTV/Views/SearchView/SearchWrapper.swift

import SwiftUI

/**
 
 */
@available(*, deprecated, message: "No longer needed use searchable view modifier")
struct SearchBar<Content: View>: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIViewController
    
    @Binding var text: String
    
    var placeholder: String = ""
    
    @ViewBuilder var content: () -> Content

    class Coordinator: NSObject, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

        @Binding var text: String
        
        init(text: Binding<String> ) {
            _text = text
        }

        // MARK: - UISearchResultsUpdating impl
        
        // Called when user selects one of the search suggestion buttons displayed under the keyboard on tvOS.
        func updateSearchResults(for searchController: UISearchController) {
            log.trace( "updateSearchResults text = \(searchController.searchBar.text ?? "")")
            
            if isInPreviewMode {
                self.text = "test in preview"
                return
            }
            
            // IMPORTANT!!!
            // only if text has changed it will be reassigned.
            // reassignment implies a content view update
            if( self.text != searchController.searchBar.text ) {
                self.text = searchController.searchBar.text ?? ""
            }
        }
        
        // Called when user selects one of the search suggestion buttons displayed under the keyboard on tvOS.
//      func updateSearchResults(for searchController: UISearchController, selecting searchSuggestion: UISearchSuggestion)

        // MARK: - UISearchBarDelegate impl
        
//        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool  { // return NO to not become first responder
//            print( "searchBarShouldBeginEditing" )
//            return true
//        }
//
//        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool  { // return NO to not become first responder
//            print( "searchBarShouldEndEditing" )
//            return true
//        }
//
//        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
//            print( "searchBarTextDidBeginEditing")
//        }
//
//        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//            print( "searchBarTextDidEndEditing")
//
//        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SearchBar>) -> UIViewControllerType {

        let topController = UIHostingController(rootView: content() )
        
        let searchController =  UISearchController(searchResultsController: topController)
        searchController.searchResultsUpdater = context.coordinator
        searchController.searchBar.delegate = context.coordinator
        // searchController.delegate = context.coordinator

        searchController.searchBar.placeholder = placeholder
        
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        // return searchContainer
        
        let searchNavigationController = UINavigationController(rootViewController: searchContainer)

        return searchNavigationController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<SearchBar>) {
        // log.trace( "updateUIViewController - searchText:\(text)" )

        //if let vc = uiViewController as? UISearchContainerViewController {
        if let vc = uiViewController.children.first as? UISearchContainerViewController {

            if let searchResultController = vc.searchController.searchResultsController, let host = searchResultController as? UIHostingController<Content> {
                
                host.rootView = content()
            }

        }
    }

}
