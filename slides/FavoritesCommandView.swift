//
//  FavoriteCommandsView.swift
//  slides
//
//  Created by softphone on 26/06/2017.
//  Copyright © 2017 soulsoftware. All rights reserved.
//

import UIKit

class FavoritesCommandView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
  
    */
    
    
    /*
    @IBOutlet var commandButtons: [UIButton]!

    private var _preferredFocusEnvironments:[UIFocusEnvironment]?
    
    override var preferredFocusEnvironments : [UIFocusEnvironment] {
        return _preferredFocusEnvironments ?? super.preferredFocusEnvironments
    }
    
    func select() {
        let firstButton = commandButtons[0]
        _preferredFocusEnvironments = [firstButton]
        setNeedsFocusUpdate()
    }
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        print( "UIFavoriteCell.shouldUpdateFocusInContext: \(context.focusHeading)" )
        
        if context.focusHeading == .up || context.focusHeading == .down {
            _preferredFocusEnvironments = []
            return true
        }
        
        if context.focusHeading == .left || context.focusHeading == .right {
            let tag = context.nextFocusedView?.tag
            
            let button =  (tag == 0 ) ? commandButtons[1] : commandButtons[0];
            
            _preferredFocusEnvironments = [button]
            return true
        }
        
        return false
    }
    
    */
}
