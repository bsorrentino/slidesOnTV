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


enum SettingsBarItem : Int {
    
    case UNKNOWN = 0
    case FULL_SCREEN = 1
    case ADD_TO_FAVORITE = 2
    
}

class SettingsBarView : UITabBar, UITabBarDelegate, NameDescribable {
    
    typealias ItemSelection = (item:SettingsBarItem, step:Int)

    var rx_didPressItem: ControlEvent<SettingsBarItem> {
        
        let result = super.rx.didSelectItem
            .filter { item in
               self.selectedItem == item
            }
            .map { item -> SettingsBarItem in
                (SettingsBarItem( rawValue: item.tag ) ?? SettingsBarItem.UNKNOWN)
            }

        return ControlEvent<SettingsBarItem>( events: result)
    }
    
    func resetSelection() {
        self.selectedItem = self.items?[0]
    }
    
    // MARK: Standard Lifecycle
    
    override func awakeFromNib() {
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    // MARK: Focus Management
    
    override var canBecomeFocused: Bool {
        //print( "\(typeName).canBecomeFocused:" )
        return false
    }
    
//    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
//        print( "\(typeName).shouldUpdateFocus:" )
//        return context.focusHeading == .left || context.focusHeading == .right
//    }
//
//    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//        print( "\(typeName).didUpdateFocus:" );
//    }
    
    
}


