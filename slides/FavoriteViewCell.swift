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
    
    /*
     private var _preferredFocusEnvironments:[UIFocusEnvironment]? {
     didSet {
     if _preferredFocusEnvironments == nil {
     self.editingAccessoryView?.removeFromSuperview()
     }
     }
     }
     
     override var preferredFocusEnvironments : [UIFocusEnvironment] {
     return _preferredFocusEnvironments ?? super.preferredFocusEnvironments
     }
     
     
     override func setEditing(_ editing: Bool, animated: Bool) {
     print( "setEditing \(editing)")
     super.setEditing(editing, animated: animated)
     
     if editing {
     _preferredFocusEnvironments = [self.editingAccessoryView!]
     }
     else {
     _preferredFocusEnvironments = nil
     }
     setNeedsFocusUpdate()
     updateFocusIfNeeded()
     }
     
     override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
     
     print( "\(String(describing: type(of: self))).shouldUpdateFocus: \(describing(context.focusHeading))" )
     
     if context.focusHeading == .left || context.focusHeading == .right {
     if context.nextFocusedView == self {
     // GAIN FOCUS
     
     } else if context.previouslyFocusedView == self {
     // LOST FOCUS
     }
     self.editingAccessoryView?.setNeedsFocusUpdate()
     
     }
     return true
     }
     */
    /*
     override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
     super.didUpdateFocus(in: context, with: coordinator)
     
     if context.nextFocusedView == self {
     // GAIN FOCUS
     
     print( "GAIN FOCUS \(self.textLabel?.text ?? "undef")")
     
     } else if context.previouslyFocusedView == self {
     // LOST FOCUS
     
     print( "LOST FOCUS \(self.textLabel?.text ?? "undef")")
     }
     }
     */
}

