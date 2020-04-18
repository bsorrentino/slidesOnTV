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
        
        // set margin
        if let view = searchResultsController.collectionView {
             view.frame = view.frame.insetBy(dx: 30, dy: 20 )
        }
        
        let searchController = UISearchController(searchResultsController: searchResultsController)
        // Contain the `UISearchController` in a `UISearchContainerViewController`.

        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.placeholder = "Search for slides" //NSLocalizedString("what", comment: "")
        
        // Apperance
        let bgColor = searchResultsController.collectionView.backgroundColor
        //searchResultsController.view.backgroundColor = bgColor
        if searchResultsController.traitCollection.userInterfaceStyle == .dark  {
            searchController.view.backgroundColor = .systemBlue
        }
        else {
            searchController.view.backgroundColor = bgColor
            searchController.searchBar.backgroundColor = .white
        }

        let searchContainer = UISearchContainerViewController(searchController: searchController)
        //searchContainer.title = NSLocalizedString("Search for slides", comment: "")

        return searchContainer
        
    }
 
}
