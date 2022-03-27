//
//  PDFView+UIKit.swift
//  Samples
//
//  Created by Bartolomeo Sorrentino on 06/03/2020.
//  Copyright © 2020 mytrus. All rights reserved.
//

import SwiftUI
import Combine
import GameController

class PageContainerView: UIView, NameDescribable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //common func to init our view
    private func setupView() {
        // backgroundColor = .red
        
        isUserInteractionEnabled = true
        
        // Setup Pointer
//        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePointer) )
//
//        tap.numberOfTapsRequired = 2
//
//        addGestureRecognizer(tap)
        
    }

    
//    @objc private func togglePointer(_ sender: UITapGestureRecognizer) {
//
//        print( "\(typeName).togglePointer \(showPointer)")
//
//        showPointer.toggle()
//
//    }

    // MARK: - Shadow management
    // MARRK: -
    
    private func addShadow(withHeight height: Int = 0) {
        
        if let page = self.subviews.first {
            page.layer.masksToBounds = false
            page.layer.shadowColor = UIColor.black.cgColor
            page.layer.shadowOpacity = 1
            page.layer.shadowOffset = CGSize(width: 0 , height: height)
            page.layer.shadowRadius = 10
            page.layer.cornerRadius = 0.0
        }
    }
    private func removeShadow() {
        
        if let page = self.subviews.first {
            page.layer.masksToBounds = false
            page.layer.shadowColor = UIColor.clear.cgColor
            page.layer.shadowOpacity = 0.0
            page.layer.shadowOffset = .zero
            page.layer.shadowRadius = 0.0
            page.layer.cornerRadius = 0.0
        }
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
        print( "\(type(of: self)).didUpdateFocusInContext: focused: \(self.isFocused)" );
        
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
        
        let pointer = UIView( frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
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
    
    let showPointerSubject = CurrentValueSubject<Bool, Never>(false)
    
    var showPointer:Bool = false {
        
        didSet {
            
            if !showPointer {
                pointer.removeFromSuperview()
            }
            else if !oldValue {
                pointer.frame.origin = self.center
                addSubview(pointer)
            }
            
            showPointerSubject.send( showPointer )
            
        }
    }
    
    // MARK: - Touch Handling
    // MARK: -
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print( "\(type(of: self)).touchesBegan: focused: \(self.isFocused)" );
        
        guard showPointer, let firstTouch = touches.first else {
            return
        }
        
        let locationInView = firstTouch.location(in: firstTouch.view)
        
        var f = pointer.frame
        f.origin = locationInView
        
        pointer.frame = f
    }
    
    override func  touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        print( "\(type(of: self)).touchesMoved: focused: \(self.isFocused)" )
        guard showPointer, let firstTouch = touches.first else {
            return
        }
        
        let locationInView = firstTouch.location(in: firstTouch.view )
        
        var f = pointer.frame
        
        f.origin = locationInView
        
        pointer.frame = f
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print( "\(type(of: self)).touchesEnded: focused: \(self.isFocused)" )
        showPointer = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print( "\(type(of: self)).touchesCancelled: focused: \(self.isFocused)" )
        showPointer = false
    }
    
}

public protocol PDFPageDelegate {
    
    func pointerStatedDidChange( show: Bool ) -> Void

    func pageDidChange( page: Int ) -> Void
}

/**
 PDFPageViewController
 */
class PDFPageViewController : UIViewController, NameDescribable {
    
    typealias Value = (newValue:Int,oldValue:Int)
    
    fileprivate var pagesCache = NSCache<NSNumber,PDFPageView>()
    
    fileprivate var document : PDFDocument
    
    fileprivate let currentPageIndexSubject = CurrentValueSubject<Value,Never>( (newValue:0,oldValue:0) )
    
    var pageDelegate: PDFPageDelegate?
    
    var currentPageIndex:Int = 0 {
        didSet {
            guard currentPageIndex != oldValue else {return}
            currentPageIndexSubject.send( (newValue:currentPageIndex, oldValue:oldValue) )
        }
    }
    
    init( document:PDFDocument ) {
        self.document = document
        super.init(nibName:nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var subscribers =  Set<AnyCancellable>()
    
    override func loadView() {
        let mainView = PageContainerView()
        
        self.view = mainView
        
        mainView.showPointerSubject.sink { show in
            
            if let delegate = self.pageDelegate  {
                delegate.pointerStatedDidChange(show: show)
            }
        }.store( in: &subscribers)
    }
    
    
    fileprivate func onUpdateCurrentPageIndex( newValue:Int, oldValue:Int ) {
        
        print( "current page index changed from \(oldValue) to \(newValue)")
        
        if( oldValue > 0 /*&& oldValue <= self.pages.count*/ ) {
            let zeroBasedIndex = NSNumber( value: oldValue - 1 )
            
            if let view = self.pagesCache.object(forKey: zeroBasedIndex)  {
                view.removeFromSuperview()
                
                print( "remove view at index \(zeroBasedIndex)" )
            }
        }
        if( newValue > 0 /*&& oldValue <= self.pages.count*/ ) {
            
            let zeroBasedIndex = NSNumber( value: newValue - 1 )
            
            guard let cachedView = self.pagesCache.object(forKey: zeroBasedIndex) else {
                
                print( "create view at index \(zeroBasedIndex)" )
                
                let newView = PDFPageView( frame: self.view.frame,
                                           document: self.document,
                                           pageNumber: zeroBasedIndex.intValue,
                                           backgroundImage: nil,
                                           pageViewDelegate: nil)
                
                newView.isUserInteractionEnabled = false
                self.view.addSubview(newView)

                self.pagesCache.setObject(newView, forKey: zeroBasedIndex)
                return
            }
            
            print( "reuse view at index \(zeroBasedIndex)" )
            
            self.view.addSubview(cachedView)
            
        }
        
    }
    
    var onUpdateCurrentPageIndexSubscriber:AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        
        super.viewWillAppear(animated)
        
        onUpdateCurrentPageIndexSubscriber =
            currentPageIndexSubject.sink {
                self.onUpdateCurrentPageIndex( newValue:$0.newValue, oldValue:$0.oldValue )
            }
    }
    
    override func viewDidDisappear(_ animated:Bool) {
        super.viewDidDisappear(animated)
        
        if let subscriber = onUpdateCurrentPageIndexSubscriber {
            subscriber.cancel()
        }
        onUpdateCurrentPageIndexSubscriber = nil
    }
    
    // MARK: - Focus Engine
    // MARK: -
    //    override var preferredFocusEnvironments: [UIFocusEnvironment] {
    //        print( "\(type(of: self)).preferredFocusEnvironments")
    //
    //        return [view]
    //    }
    
    // MARK: - Presses Handling
    // MARK: -

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("\(typeName).pressesBegan")

        
        if let press = presses.first {
 
            switch press.type {
            case .playPause:
                print( "playPause" )
                break
            case .downArrow:
                print( "downArrow" )
                break
            case .upArrow:
                print( "upArrow" )
                break
            case .leftArrow:
                print( "leftArrow" )
                pageDelegate?.pageDidChange(page: self.currentPageIndex - 1)
                break
            case .rightArrow:
                print( "rightArrow" )
                pageDelegate?.pageDidChange(page: self.currentPageIndex + 1)
                break
            case .select:
                print( "select" )
                if let view = self.view as? PageContainerView {
                    view.showPointer.toggle()
                }
                break
            default:
                print("press.type=\(press.type.rawValue)")
                super.pressesBegan(presses, with: event)
                break
            }
             

        }
        
        
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        //print("\(typeName).pressesEnded")
        super.pressesEnded(presses, with: event)
    }
    
    
    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesChanged(presses, with: event)
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesCancelled(presses, with: event)
    }

}


struct PDFDocumentView : UIViewControllerRepresentable, PDFPageDelegate {
    
    
    typealias UIViewControllerType = PDFPageViewController
    
    
    var document : PDFDocument
    @Binding var page:Int
    @Binding var isPointerVisible:Bool
    var isZoom:Bool
    
    func pointerStatedDidChange( show: Bool ) {
        DispatchQueue.main.async {
            print( "pointerStatedDidChange \(show)")
            isPointerVisible = show
        }
    }
    
    func pageDidChange(page: Int) {
        if isZoom && page > 0 && page <= document.pageCount {
            DispatchQueue.main.async {
                self.page = page
            }
        }
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<PDFDocumentView>) -> UIViewControllerType {
        
        let controller = PDFPageViewController( document: document )
        
        controller.pageDelegate = self
        controller.currentPageIndex = page
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<PDFDocumentView>) {
        
        uiViewController.currentPageIndex = page
    }
    
}

