//
//  FavoriteViewCell.swift
//  slides
//
//  Created by softphone on 28/06/2017.
//  Copyright © 2017 soulsoftware. All rights reserved.
//

import Foundation

class UIFavoriteCell : UITableViewCell {
    
    
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if  let selectedView = self.selectedBackgroundView as? FavoritesCommandView,
            let progressView = selectedView.downloadProgressView {
            
            progressView.progress = 0.0
        }
        
    }

    // MARK: FOCUS MANAGEMENT

    /*
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {

        print( "\(String(describing: type(of: self))).shouldUpdateFocus: \(describing(context.focusHeading))" )
     
        if context.focusHeading == .left || context.focusHeading == .right {
            if context.nextFocusedView == self {
                // GAIN FOCUS
            } else if context.previouslyFocusedView == self {
                // LOST FOCUS
            }
            
        }
        
        return true
    }
    */
}

