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
    
    let hiddenSubject = PublishSubject<(hidden:Bool,preferredFocusedView:UIView?)>()
    
    // MARK: public implementation
    
    lazy var showConstraints:NSLayoutConstraint = {
        let h =  self.heightAnchor.constraint( equalToConstant: 140.0)
        h.priority = UILayoutPriority(rawValue: 1000)
        return h
    }()
    
    lazy var hideConstraints:NSLayoutConstraint = {
        let h =  self.heightAnchor.constraint(equalToConstant: 1.0)
        h.priority = UILayoutPriority(rawValue: 1000)
        return h
    }()
    
    func hide(animated:Bool, preferredFocusedView:UIView? = nil) {
        
        guard !self.hideConstraints.isActive else {
            return
        }
        
        self.showConstraints.isActive = false
        self.hideConstraints.isActive = true
        
        if animated {
            UIView.animate(withDuration: 0.5, animations: { self.superview?.layoutIfNeeded() }) 
        }

        hiddenSubject.onNext(( hidden:true, preferredFocusedView:preferredFocusedView) )
        
    }
    
    func show(animated:Bool) {
        guard !self.showConstraints.isActive else {
            return
        }
        
        self.hideConstraints.isActive = false
        self.showConstraints.isActive = true
        
        if animated {
            UIView.animate(withDuration: 0.5, animations: { self.superview?.layoutIfNeeded() }) 
        }

        hiddenSubject.onNext(( hidden:false, preferredFocusedView:self) )
        
    }

    var active: Bool {
        get {
            return self.showConstraints.isActive
        }
    }

    // MARK: RX 
    
    var rx_didHidden: ControlEvent<(hidden:Bool,preferredFocusedView:UIView?)> {
        return ControlEvent<(hidden:Bool,preferredFocusedView:UIView?)>( events: hiddenSubject )
    }
    
    var rx_didPressItem: ControlEvent<Int> {
        let first = super.rx.didSelectItem.map { (item:UITabBarItem) -> Int in
            return item.tag
        }
        
        let second = hiddenSubject
            //.filter { (hidden:Bool) -> Bool in
            //    return !hidden
            //}
            .map { (hidden:Bool,preferredFocusedView:UIView?) -> Int in
                return 0
            }
        
        let result =  Observable.from([first, second])
            .merge()
            .scan( (key:0, step:0), accumulator: { (last, item:Int) -> (key:Int, step:Int) in
                
                var step = 1
                if item == last.key {
                    step = last.step + 1
                }
                
                return (key:item, step:step)
            })
            .filter { (item) -> Bool in
                return item.step >= 2
            }
            .do( onNext: { (key, step) in
                print( "key: \(key) step: \(step)")
            })
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
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        print( "UISettingsBarView.shouldUpdateFocusInContext:" )
        return context.focusHeading == .left || context.focusHeading == .right
        
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        print( "UISettingsBarView.didUpdateFocusInContext:\(context.focusHeading)" );
    }
    
    
}


