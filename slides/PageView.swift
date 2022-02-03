//
//  PageView.swift
//  slides
//
//  Created by softphone on 26/09/2016.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import UIKit
import RxRelay

class PageView: UIView, NameDescribable {

    @IBOutlet weak var pageImageView: UIImageView!
    
    // MARK: - Shadow management
    // MARRK: -
    
    private func addShadow(_ height: Int = 0) {
        
        self.pageImageView.layer.masksToBounds = false
        self.pageImageView.layer.shadowColor = UIColor.black.cgColor
        self.pageImageView.layer.shadowOpacity = 1
        self.pageImageView.layer.shadowOffset = CGSize(width: 0 , height: height)
        self.pageImageView.layer.shadowRadius = 10
        self.pageImageView.layer.cornerRadius = 0.0

     }

     private func removeShadow() {

        self.pageImageView.layer.masksToBounds = false
        self.pageImageView.layer.shadowColor = UIColor.clear.cgColor
        self.pageImageView.layer.shadowOpacity = 0.0
        self.pageImageView.layer.shadowOffset = .zero
        self.pageImageView.layer.shadowRadius = 0.0
        self.pageImageView.layer.cornerRadius = 0.0
     }
    
    // MARK: - standard lifecycle
    // MARK: -

    override func didMoveToSuperview() {
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    // MARK: - Focus Management
    // MARK: -
    
    override var canBecomeFocused : Bool {
        return true
    }
//
//    /// Asks whether the system should allow a focus update to occur.
//    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
//        print( "PageView.shouldUpdateFocusInContext:" )
//        return true
//
//    }
    
    /// Called when the screen’s focusedView has been updated to a new view. Use the animation coordinator to schedule focus-related animations in response to the update.
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        print( "\(typeName).didUpdateFocusInContext: focused: \(self.isFocused)" );

        coordinator.addCoordinatedAnimations(nil) {
          // Perform some task after item has received focus
            if context.nextFocusedView == self {
                self.addShadow()
            }
            else {
                self.removeShadow()
            }
        }
    }
    
    // MARK: - Pointer Management
    // MARK: -
    
    fileprivate lazy var pointer:UIView = {
        
        let pointer:UIView = UIView( frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        pointer.backgroundColor = UIColor.magenta
        pointer.isUserInteractionEnabled = false
        
        pointer.layer.cornerRadius = 10.0
        
        // border
        pointer.layer.borderColor = UIColor.lightGray.cgColor
        pointer.layer.borderWidth = 1.5
        
        // drop shadow
        pointer.layer.shadowColor = UIColor.black.cgColor
        pointer.layer.shadowOpacity = 0.8
        pointer.layer.shadowRadius = 3.0
        pointer.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        
        return pointer
        
    }()
    
    let showPointerRelay = BehaviorRelay<Bool>( value: false )
    
    var showPointer:Bool = false {
        
        didSet {

            if !showPointer {
                pointer.removeFromSuperview()
            }
            else if !oldValue {
                pointer.frame.origin = self.center
                addSubview(pointer)
            }
            
            showPointerRelay.accept( showPointer )

        }
    }
    
    // MARK: - Touch Handling
    // MARK: -
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard showPointer, let firstTouch = touches.first else {
            return
        }
        
        let locationInView = firstTouch.location(in: firstTouch.view)
        
        var f = pointer.frame
        f.origin = locationInView
        
        pointer.frame = f
    }
    
    override func  touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard showPointer, let firstTouch = touches.first else {
            return
        }
        
        let locationInView = firstTouch.location(in: firstTouch.view)
        
        var f = pointer.frame
        f.origin = locationInView
        
        pointer.frame = f
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        showPointer = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        showPointer = false
    }
    
    

}
