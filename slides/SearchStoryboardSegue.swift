//
//  SearchStoryboardSegue.swift
//  slides
//
//  Created by softphone on 28/05/2017.
//  Copyright © 2017 soulsoftware. All rights reserved.
//

import UIKit

class SearchStoryboardSegue: UIStoryboardSegue {

    override func perform() {
        
        
        if let searchNavigationController = super.destination as? UINavigationController {

            print( "SearchStoryboardSegue" )
            
            guard let searchResultsController = searchNavigationController.viewControllers[0] as? SearchSlidesViewController else {
                
                fatalError("the configurated root controller in Storyboard is not of type 'SearchResultsViewController'!.")
            }
            
            let searchContainer = packagedSearchController( searchResultsController: searchResultsController )

            searchNavigationController.setViewControllers([searchContainer], animated: false)
            

            super.perform()
            
        }
        
    }
    
    func packagedSearchController( searchResultsController:SearchSlidesViewController ) -> UISearchContainerViewController {
        
        let searchController = UISearchController(searchResultsController: searchResultsController)
        
        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.placeholder = NSLocalizedString("what", comment: "")
        
        // Contain the `UISearchController` in a `UISearchContainerViewController`.
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        //searchContainer.title = NSLocalizedString("Search for slides", comment: "")
        
        return searchContainer
        
    }
    
}
