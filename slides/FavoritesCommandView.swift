//
//  FavoriteCommandsView.swift
//  slides
//
//  Created by softphone on 26/06/2017.
//  Copyright © 2017 soulsoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavoritesCommandView: UIView {

    @IBOutlet weak var downloadProgressView: UIProgressView!
   
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    /*
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
  
    */

    // MARK: FOCUS MANAGEMENT
    /*
    private var _preferredFocusIndex:Int = 0
    
    override var preferredFocusEnvironments : [UIFocusEnvironment] {
        return [ commandButton[_preferredFocusIndex] ]
    }
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        
        print( "\(String(describing: type(of: self))).shouldUpdateFocus: \(describing(context.focusHeading))" )
        
        if context.focusHeading == .up || context.focusHeading == .down {
            _preferredFocusIndex = 0
        }
        else if context.focusHeading == .left || context.focusHeading == .right {
            let tag = context.previouslyFocusedView?.tag
            
            _preferredFocusIndex =  (tag == 0 ) ? 1 : 0;
        }
        
        return true
    }
    */
        
}
