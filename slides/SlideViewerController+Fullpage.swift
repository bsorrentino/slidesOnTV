//
//  SlideViewer+Fullpage.swift
//  slides
//
//  Created by softphone on 01/10/2016.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import Foundation

extension UIPDFCollectionViewController {
    
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
    
}
