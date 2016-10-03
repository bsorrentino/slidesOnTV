//
//  AppDelegate.swift
//  slides
//
//  Created by softphone on 31/03/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if let w = window {

            // Reccomendation from WWDC 2016 - Desiging for TvOS - https://developer.apple.com/videos/play/wwdc2016/802/

            w.frame = CGRectInset( w.frame, 90, 60 )
            
        }
        
        window?.rootViewController = packagedSearchController()
        
        // ONLY FOR TEST PURPOSE
        //window?.rootViewController = testController()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func testController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let controller = storyboard.instantiateViewControllerWithIdentifier(UIPDFCollectionViewController.storyboardIdentifier) as? UIPDFCollectionViewController else {
            fatalError("Unable to instatiate a UIPDFCollectionViewController from the storyboard.")
        }
    
        if let path = NSBundle.mainBundle().pathForResource("rx1", ofType:"pdf") {

            controller.documentLocation = NSURL.fileURLWithPath(path)
        }

        return controller
    }
    

    func packagedSearchController() -> UIViewController {
        // Load a `SearchResultsViewController` from its storyboard.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let searchResultsController = storyboard.instantiateViewControllerWithIdentifier(SearchSlidesViewController.storyboardIdentifier) as? SearchSlidesViewController else {
            fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
        }
        
        /*
         Create a UISearchController, passing the `searchResultsController` to
         use to display search results.
         */
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.placeholder = NSLocalizedString("what", comment: "")
        
        // Contain the `UISearchController` in a `UISearchContainerViewController`.
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        searchContainer.title = NSLocalizedString("Search", comment: "")
        
        // Finally contain the `UISearchContainerViewController` in a `UINavigationController`.
        let searchNavigationController = UINavigationController(rootViewController: searchContainer)
        return searchNavigationController
    }
}

