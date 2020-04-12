//
//  PDFCollectionViewController+AutoLayout.swift
//  slides
//
//  Created by softphone on 12/09/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import Foundation

let layoutAttrs = (
    cellSize: CGSize(width: 400,height: 250),
    numCols: 1,
    minSpacingForCell: CGFloat(25.0),
    minSpacingForLine: CGFloat(35.0)
)

extension UIPDFCollectionViewController {
    
    var thumbnailsWidth:CGFloat {
        get {
            return  CGFloat(layoutAttrs.numCols) *
                CGFloat(layoutAttrs.cellSize.width + (CGFloat(layoutAttrs.numCols - 1) * layoutAttrs.minSpacingForCell))
        }
    }
    
    override func updateViewConstraints() {
        
        let frame_width = view.frame.size.width - 60 // ignore insets

        let w = (self.fullpage) ? 0 : self.thumbnailsWidth
        
        let pageViewWidth = frame_width - w
        
        pageView.snp.updateConstraints { make in
            
            make.width.equalTo( pageViewWidth ).priority( 1000 ) // required
        }
        
        pagesView.snp.updateConstraints { make in
            
            make.width.equalTo( w ).priority( 750 ) // high
        }
        
        pageImageView.snp.updateConstraints { make in
            
            let delta = pageViewWidth * 0.10
            let newWidth = pageViewWidth - delta
            
            make.width.equalTo(newWidth).priority( 1000 ) // required
        }
        
        super.updateViewConstraints()
    }
    
}
