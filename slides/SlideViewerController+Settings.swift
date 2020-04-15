//
//  SlideViewer+Fullpage.swift
//  slides
//
//  Created by softphone on 01/10/2016.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import Foundation
import RxSwift
extension UIPDFCollectionViewController : SettingsDelegate {
        
    func setupSettingsBar() {
        
        guard let settingsViewController = children.first as? SettingsViewController else  {
          return
        }
        
        self.settingsViewController = settingsViewController
        settingsViewController.delegate = self
    
    }

    // MARK: - Fullsceen
    // MARK: -
    func toggleFullscreen(_ sender: SettingButton) {

        print( "\(self.typeName) fullpage \(!self.fullpage)")
        
        self.fullpage = !self.fullpage
        
        self.setNeedsFocusUpdate()

    }

    func showThumbnails() {
        print( "\(typeName).showThumbnails")
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions(), animations: {
            
            let w = self.thumbnailsWidth
            
            var page_frame = self.pageView.frame
            page_frame.origin.x += w
            self.pageView.frame = page_frame
            
            
            var pages_frame = self.thumbnailsView.frame
            pages_frame.size.width = w
            self.thumbnailsView.frame = pages_frame
            
            
        } ) { (completion:Bool) in
            
        }
        
        
    }
    
    func hideThumbnails()  {
        print( "\(typeName).hideThumbnails")
        
        let width = self.thumbnailsView.frame.size.width
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions() , animations: {
            
            var pages_frame = self.thumbnailsView.frame
            pages_frame.size.width = 0
            self.thumbnailsView.frame = pages_frame
            
            var page_frame = self.pageView.frame
            page_frame.origin.x -= width
            self.pageView.frame = page_frame
            
            
        }) { (completion:Bool) in
            
        }
    }
 
    // MARK: - add to favorite
    // MARK: -

    func addToFavorite(_ sender: SettingButton) {
        print( "\(self.typeName) save to favorite \(!self.fullpage)")
        
        guard let documentInfo = self.documentInfo else {
            return
        }
            
        rxFavoriteStore(data: documentInfo)
            .subscribe( onCompleted: {

                print("\(self.typeName) Favorite stored")

                self.setNeedsFocusUpdate()
            })
            .disposed(by: disposeBag)

    }


}
