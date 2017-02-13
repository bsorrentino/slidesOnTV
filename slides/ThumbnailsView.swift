//
//  ThumbnailsView.swift
//  slides
//
//  Created by softphone on 27/09/2016.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import UIKit

class ThumbnailsView: UICollectionView {

    // MARK: Focus Management
    
    /// Asks whether the system should allow a focus update to occur.
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        print( "ThumbnailsView.shouldUpdateFocusInContext:" )
        return true
        
    }
    
    /// Called when the screen’s focusedView has been updated to a new view. Use the animation coordinator to schedule focus-related animations in response to the update.
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        print( "ThumbnailsView.didUpdateFocusInContext: focused: \(self.isFocused)" );
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
}
