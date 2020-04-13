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
            .map { item -> SettingsBarItem in
                (SettingsBarItem( rawValue: item.tag ) ?? SettingsBarItem.UNKNOWN)
            }
            // TRANSFORM "SELECTED ITEM" IN "PRESSED ITEM" (DOUBLE SELECTION)
            .scan( ( item:.UNKNOWN, step:0 ), accumulator: { (last, item) -> ItemSelection in
                var step = 1
                if item == last.item {
                    step = last.step + 1
                }
                return (item:item, step:step)
            })
            .filter { item in
                item.step >= 2
            }
            .map { item in
                item.item
            }

        return ControlEvent<SettingsBarItem>( events: result)
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
        print( "\(typeName).canBecomeFocused:" )
        return false
    }
    
//    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
//        print( "\(typeName).shouldUpdateFocus:" )
//        return context.focusHeading == .left || context.focusHeading == .right
//
//    }
//
//    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//        print( "\(typeName).didUpdateFocus:" );
//    }
    
    
}


