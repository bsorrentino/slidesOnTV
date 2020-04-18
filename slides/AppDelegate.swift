//
//  AppDelegate.swift
//  slides
//
//  Created by softphone on 31/03/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        /*
        if let w = window {

            // Reccomendation from WWDC 2016 - Desiging for TvOS - https://developer.apple.com/videos/play/wwdc2016/802/
            w.frame = w.frame.insetBy(dx: 90, dy: 60 )
            
        }
        */
        
        //window?.rootViewController = packagedSearchController()
        
        // ONLY FOR TEST PURPOSE
        //window?.rootViewController = testController()

        //addFavoriteDataForTest()
        
        return true
    }

    private func addFavoriteDataForTest() {
        
        let testFavorites:[DocumentInfo] = [
            DocumentInfo( location:URL(string:"http://pippo.com")!, id:"1", title:"test1" ),
            DocumentInfo( location:URL(string:"http://pippo.com")!, id:"2", title:"test2" ),
            DocumentInfo( location:URL(string:"http://pippo.com")!, id:"3", title:"test3" ),
            DocumentInfo( location:URL(string:"http://pippo.com")!, id:"4", title:"test4" ),
            DocumentInfo( location:URL(string:"http://pippo.com")!, id:"5", title:"test5" )
        ]
        
        let _ = Observable.from(testFavorites).flatMap {
            (d) in
            
            return rxFavoriteStore(data: d)
            }
            .subscribe( onCompleted: {
                print( "inserted")
            })
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func testController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: UIPDFCollectionViewController.storyboardIdentifier) as? UIPDFCollectionViewController else {
            fatalError("Unable to instatiate a UIPDFCollectionViewController from the storyboard.")
        }
    
        if let path = Bundle.main.path(forResource: "rx1", ofType:"pdf") {

            controller.documentInfo?.location = URL(fileURLWithPath: path)
        }

        return controller
    }
    

}


