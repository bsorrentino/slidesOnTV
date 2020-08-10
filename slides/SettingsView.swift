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
                
                //self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
                self.layer.shadowColor      = UIColor.black.withAlphaComponent(0.50).cgColor
                self.layer.shadowOffset     = CGSize(width: 0.0, height: 3.0)
                self.layer.shadowOpacity    = 1.0
                self.layer.shadowRadius     = 0.0
                self.layer.masksToBounds    = false
                self.layer.cornerRadius     = 4.0
            }
            else {
                self.layer.shadowColor = UIColor.clear.cgColor
            }
        }
    }

}
