//
//  SettingsBarView.swift
//  slides
//
//  Created by softphone on 09/09/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

class SettingsBarView : UITabBar {
    
    // MARK: public implementation
    
    lazy var showConstraints:NSLayoutConstraint = {
        let h =  self.heightAnchor.constraintEqualToConstant( 140.0)
        h.priority = 1000
        return h
    }()
    
    lazy var hideConstraints:NSLayoutConstraint = {
        let h =  self.heightAnchor.constraintEqualToConstant(1.0)
        h.priority = 1000
        return h
    }()
    
    func hide(animated animated:Bool) {
        
        guard !self.hideConstraints.active else {
            return
        }
        
        self.showConstraints.active = false
        self.hideConstraints.active = true
        
        if animated {
            UIView.animateWithDuration(0.5) { self.superview?.layoutIfNeeded() }
        }
        
        
    }
    
    func show(animated animated:Bool) {
        guard !self.showConstraints.active else {
            return
        }
        
        self.hideConstraints.active = false
        self.showConstraints.active = true
        
        if animated {
            UIView.animateWithDuration(0.5) { self.superview?.layoutIfNeeded() }
        }
        
    }

    var active: Bool {
        get {
            return self.showConstraints.active
        }
    }
    
    // MARK: Standard Lifecycle
    
    override func didMoveToSuperview() {
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    // MARK: Focus Management
    //override func canBecomeFocused() -> Bool {
    //    print( "UISettingsBarView.canBecomeFocused:" )
    //    return true
    //}
    
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        print( "UISettingsBarView.shouldUpdateFocusInContext:" )
        return context.focusHeading == .Left || context.focusHeading == .Right
        
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        print( "UISettingsBarView.didUpdateFocusInContext:\(context.focusHeading)" );
    }
    
    
}


