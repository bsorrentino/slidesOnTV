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


class SettingsBarView : UITabBar, UITabBarDelegate {
    
    class Notifications {
        static let HIDDEN = "settings.hidden"
    }
    
    let hiddenSubject = PublishSubject<Bool>()
    
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

        hiddenSubject.onNext(true)
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.HIDDEN, object: true)
        
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

        hiddenSubject.onNext(false)
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.HIDDEN, object: false)
        
    }

    var active: Bool {
        get {
            return self.showConstraints.active
        }
    }

    // MARK: RX 
    
    var rx_didPressItem: ControlEvent<Int> {
        
        let first = self.rx_didSelectItem.map { (item:UITabBarItem) -> Int in
            return item.tag
        }
        
        let second = hiddenSubject.filter { (hidden:Bool) -> Bool in
                return !hidden
            }
            .map { (hidden:Bool) -> Int in
                return 0
            }
        
        let result =  [first, second]
            .toObservable()
            .merge()
            .scan( (key:0, step:0), accumulator: { (last, item:Int) -> (key:Int, step:Int) in
                
                var step = 1
                if item == last.key {
                    step = last.step + 1
                }
                
                return (key:item, step:step)
            })
            .doOnNext{ (key, step) in
                print( "key: \(key) step: \(step)")
            }
            .filter { (item) -> Bool in
                return item.step >= 2
            }
            .map { (key, step) -> Int in
                return key
            }

        return ControlEvent<Int>( events: result)
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


