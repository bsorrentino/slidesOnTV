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
        
        if let w = searchResultsController.collectionView {
            
            //var f = w.frame.insetBy(dx: 90, dy: 60 )
            var ff = w.frame
            
            ff.origin.x     = ff.origin.x + 90
            ff.size.width   = ff.size.width - 180
            ff.size.height  = ff.size.height - 60
            
            w.frame = ff
            
        }

        let searchController = UISearchController(searchResultsController: searchResultsController)
        
        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.placeholder = NSLocalizedString("what", comment: "")
        
        // Contain the `UISearchController` in a `UISearchContainerViewController`.
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        //searchContainer.title = NSLocalizedString("Search for slides", comment: "")
        
        return searchContainer
        
    }
    
}
