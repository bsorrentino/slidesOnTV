//
//  SlideViewer+Fullpage.swift
//  slides
//
//  Created by softphone on 01/10/2016.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import Foundation

extension UIPDFCollectionViewController {
    
    private struct AssociatedKeys {
        static var fullpage = "_fullpage"
    }
    
    //this lets us check to see if the item is supposed to be displayed or not
    var fullpage : Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &AssociatedKeys.fullpage) as? NSNumber else {
                return false
            }
            return number.boolValue
        }
        
        set {

            objc_setAssociatedObject(self,
                                     &AssociatedKeys.fullpage,
                                     NSNumber(bool: newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if newValue {
                showThumbnails()
            }
            else {
                hideThumbnails()
            }
            self.view.setNeedsUpdateConstraints()
            
        }
    }
    
    private func showThumbnails() {
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            var page_frame = self.pageView.frame
            page_frame.origin.x += self.thumbnailsWidth
            self.pageView.frame = page_frame
            
            
            var pages_frame = self.pagesView.frame
            pages_frame.size.width = self.thumbnailsWidth
            self.pagesView.frame = pages_frame
            
            
        } ) { (completion:Bool) in
            
        }
        
        
    }
    
    private func hideThumbnails()  {
        
        let width = self.pagesView.frame.size.width
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut , animations: {
            
            
            var pages_frame = self.pagesView.frame
            pages_frame.size.width = 0
            self.pagesView.frame = pages_frame
            
            var page_frame = self.pageView.frame
            page_frame.origin.x -= width
            self.pageView.frame = page_frame
            
            
        }) { (completion:Bool) in
            
        }
    }
    
}
