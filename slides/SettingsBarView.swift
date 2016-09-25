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

class SettingsBarView : UIView {
    
    let buttons = [ UIButton(type: .Custom), UIButton(type: .Custom), UIButton(type: .Custom) ]
    
    weak var zoomIn: UIButton? {
        return buttons[0]
    }
    weak var zoomOut: UIButton? {
        return buttons[1]
    }
    weak var rotate: UIButton? {
        return buttons[2]
    }
    
    let disposeBag = DisposeBag()
    
    let buttonSize = CGSize(width: 350, height: 50)
    
    // MARK: Private implementation
    
    private func setupView() -> Self {
        
        guard let superview = self.superview else {
            return self
        }
        
        self.backgroundColor = UIColor.darkGrayColor()
        
        if let zoomOut = self.zoomOut {
            zoomOut.setTitle("zoom -", forState: .Normal)
            zoomOut.setTitleColor( UIColor.whiteColor(), forState: .Normal)
            zoomOut.setTitleColor( UIColor.yellowColor(), forState: .Focused)
            zoomOut.backgroundColor = UIColor.clearColor()
            zoomOut.rx_primaryAction.asDriver().driveNext {
                print( "Zoom -")
                }.addDisposableTo(disposeBag)
        }
        
        if let zoomIn = self.zoomIn {
            zoomIn.setTitle("zoom +", forState: .Normal)
            zoomIn.setTitleColor( UIColor.whiteColor(), forState: .Normal)
            zoomIn.setTitleColor( UIColor.yellowColor(), forState: .Focused)
            zoomIn.backgroundColor = UIColor.clearColor()
            
            zoomIn.rx_primaryAction.asDriver().driveNext {
                print( "Zoom +")
                }.addDisposableTo(disposeBag)
        }
        
        if let rotate = self.rotate {
            
            rotate.setTitle("rotate", forState: .Normal)
            rotate.setTitleColor( UIColor.whiteColor(), forState: .Normal)
            rotate.setTitleColor( UIColor.yellowColor(), forState: .Focused)
            rotate.backgroundColor = UIColor.clearColor()
            
            rotate.rx_primaryAction.asDriver().driveNext {
                print( "Rotate")
                }.addDisposableTo(disposeBag)
            
        }
        
        
        let offsetBetweenButtons = 50
        
        
        let totalWidthCoveredByButtons = (buttons.count * Int(buttonSize.width)) + ((buttons.count - 1)*offsetBetweenButtons)
        
        let offsetFormLeading = (superview.frame.size.width - CGFloat(totalWidthCoveredByButtons))/2
        
        self.snp_makeConstraints { (make) in
            
            make.top.left.equalTo(superview).priorityRequired()
            make.width.equalTo(superview).priorityRequired()
            make.height.equalTo(1.0).priorityRequired()
        }
        
        buttons.enumerate().forEach {
            
            self.addSubview($1)
            
            if $0 == 0 {
                
                $1.snp_makeConstraints { (make) in
                    
                    makeStdButtonConstraints(make: make)
                    make.leading.equalTo(self.snp_leading).offset(offsetFormLeading)
                    
                }
                
            }
            else {
                
                let prevButton = buttons[$0-1]
                $1.snp_makeConstraints { (make) in
                    
                    makeStdButtonConstraints(make: make)
                    make.leading.equalTo(prevButton.snp_trailing).offset(offsetBetweenButtons)
                    
                }
                
            }
        }
        
        return self
    }
    
    private func makeStdButtonConstraints( make make: ConstraintMaker ) {
        
        make.height.equalTo(buttonSize.height).priorityRequired()
        make.width.equalTo(buttonSize.width).priorityRequired()
        make.top.equalTo(self).offset(15)
    }

    // MARK: public implementation
    
    func hideAnimated() {
        
        UIView.animateWithDuration(0.5, animations: {
        
            self.subviews.forEach({ (v:UIView) in
                v.alpha = 0.0
            })
        
            var f = self.frame
            f.size.height = 1.0
            self.frame = f
        
        })

    
    }
    
    func showAnimated() {
        
        UIView.animateWithDuration(0.5, animations: {
            
            var f = self.frame
            f.size.height = 80
            self.frame = f
            
            self.subviews.forEach({ (v:UIView) in
                v.alpha = 1.0
            })
            
        })

    }

    // MARK: Standard Lifecycle
    
    override func didMoveToSuperview() {
        setupView()
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
    }
    
    // MARK: Focus Management
    
    private var _preferredFocusedViewIndex:Int = 0
    private var _canBecomeFocused:Bool = true
    
    override weak var preferredFocusedView: UIView? {
        
        return ( _canBecomeFocused ) ? buttons[_preferredFocusedViewIndex] : nil
    }
    
    func canBecomeFocused( value:Bool ) {
            _canBecomeFocused = value
    }
    
    override func canBecomeFocused() -> Bool {
        
        return _canBecomeFocused
    }
    
    
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        print( "UISettingsBarView.shouldUpdateFocusInContext:" )
        
        
        let skip = ( (context.focusHeading == .Left && _preferredFocusedViewIndex == 0) ||
            (context.focusHeading == .Right && _preferredFocusedViewIndex == buttons.count - 1 ) ||
            (context.focusHeading == .Up || context.focusHeading == .Down))
        
        if( skip ) {
            _canBecomeFocused = false
            self.setNeedsFocusUpdate()
            
        }
        return !skip
        
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        print( "UISettingsBarView.didUpdateFocusInContext:\(context.focusHeading)" );
        
        switch( context.focusHeading ) {
        case UIFocusHeading.Left:
            _preferredFocusedViewIndex = _preferredFocusedViewIndex - 1
            self.setNeedsFocusUpdate()
            break
        case UIFocusHeading.Right:
            _preferredFocusedViewIndex = _preferredFocusedViewIndex + 1
            self.setNeedsFocusUpdate()
            break
        default:
            break
        }
        
        
        
    }
    
    
}


