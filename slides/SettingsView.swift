//
//  SettingsBarView.swift
//  slides
//
//  Created by softphone on 09/09/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit



class SettingButton : UIButton, NameDescribable {
    
//    override var canBecomeFocused: Bool {
//      return true
//    }

//    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
//        print( "\(typeName).shouldUpdateFocusInContext: \(context.focusHeading)" )
//        return true
//
//
//    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        print( "\(typeName).didUpdateFocusInContext: focused:" );

        super.didUpdateFocus(in: context, with: coordinator)
        
        coordinator.addCoordinatedAnimations(nil) {
          // Perform some task after item has received focus
            if context.nextFocusedView == self {
                self.layer.borderWidth = 0.5
                self.layer.borderColor = UIColor.red.cgColor
            }
            else {
                self.layer.borderWidth = 0.0
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }

}
