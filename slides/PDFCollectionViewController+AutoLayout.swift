//
//  PDFCollectionViewController+AutoLayout.swift
//  slides
//
//  Created by softphone on 12/09/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import Foundation


extension UIPDFCollectionViewController {

    private struct AssociatedKeys {
        static var fullpage = "is_fullpage"
    }
    
    //this lets us check to see if the item is supposed to be displayed or not
    var fullpage : Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &AssociatedKeys.fullpage) as? NSNumber else {
                return false
            }
            return number.boolValue
        }
        
        set(value) {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.fullpage,
                                     NSNumber(bool: value),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.view.setNeedsUpdateConstraints()

        }
    }
    
    
    override public func updateViewConstraints() {
        
        let w = (self.fullpage) ? 0 : CGFloat(layoutAttrs.numCols) * CGFloat(layoutAttrs.cellSize.width + layoutAttrs.minSpacingForCell)
        
        
        let pageViewWidth = view.frame.size.width - w
        
        pageView.snp_updateConstraints { (make) -> Void in
            
            make.width.equalTo( pageViewWidth ).priorityRequired()
        }
        
        pagesView.snp_updateConstraints { (make) -> Void in
            
            make.width.equalTo( w ).priorityHigh()
        }
        
        pageImageView.snp_updateConstraints { (make) in
            
            let delta = pageViewWidth * 0.30
            let newWidth = pageViewWidth - delta
            
            make.width.equalTo(newWidth).priorityRequired()
        }
        
        
        super.updateViewConstraints()
    }
    
    
    
}