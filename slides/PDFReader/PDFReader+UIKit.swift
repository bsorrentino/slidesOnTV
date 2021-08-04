//
//  PDFView+UIKit.swift
//  Samples
//
//  Created by Bartolomeo Sorrentino on 06/03/2020.
//  Copyright © 2020 mytrus. All rights reserved.
//

import SwiftUI
import Combine


class PageContainerView: UIView {

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
    // let tap = UILongPressGestureRecognizer(target: self, action: #selector(togglePointer) )
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePointer) )

        tap.numberOfTapsRequired = 1

        addGestureRecognizer(tap)

    }
    
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
    
    @objc private func togglePointer(_ sender: UITapGestureRecognizer) {
        
        print( "\(type(of: self)).togglePointer \(showPointer)")
        
        showPointer.toggle()

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
        print( "\(type(of: self)).touchesMoved: focused: \(self.isFocused)" );
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


/**
 PDFPageViewController
 */
class PDFPageViewController : UIViewController {
    
    typealias Value = (newValue:Int,oldValue:Int)
    
    fileprivate var pages = Array<PDFPageView>()
    
    fileprivate var document : PDFDocument
    
    fileprivate let _currentPageIndex = CurrentValueSubject<Value,Never>( (newValue:0,oldValue:0) )
    
    var currentPageIndex:Int = 0 {
        didSet {
            guard currentPageIndex != oldValue else {return}
            _currentPageIndex.send( (newValue:currentPageIndex, oldValue:oldValue) )
        }
    }
    
    init( document:PDFDocument ) {
        self.document = document
        super.init(nibName:nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var cancellable:AnyCancellable?
    
    fileprivate func updateCurrentPage() {
        
        guard cancellable == nil else { return }
        
        cancellable = _currentPageIndex.sink {
            print( "value changed \($0)")
            
            if( $0.oldValue > 0 ) {
                let view = self.pages[$0.oldValue - 1]
                view.removeFromSuperview()

                print( "remove view at index \($0.oldValue)" )
            }
            if( $0.newValue > 0 ) {
                let index = $0.newValue-1
                if( !self.pages.indices.contains(index) ) {
                    
                    print( "create view at index \($0.newValue)" )

                    let view = PDFPageView( frame: self.view.frame,
                                            document: self.document,
                                            pageNumber: index,
                                            backgroundImage: nil,
                                            pageViewDelegate: nil)
                    
                    self.pages.append( view )
                    view.isUserInteractionEnabled = false
                    self.view.addSubview(view)

                }
                else {
                    print( "reuse view at index \($0.newValue)" )

                    let view = self.pages[index]
                    self.view.addSubview(view)
                }

            }

        }
    }
    
    override func loadView() {
        
        let mainView = PageContainerView()
        
        self.view = mainView
        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        print( "viewWillAppear")
        updateCurrentPage()
        super.viewWillAppear(animated)
    }
    
    // MARK: - Focus Engine
    // MARK: -
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        print( "\(type(of: self)).preferredFocusEnvironments")
        
        return [view]
    }
        
}

struct PDFDocumentView : UIViewControllerRepresentable {
        
    typealias UIViewControllerType = PDFPageViewController

    var document : PDFDocument
    @Binding var pageSelected:Int
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PDFDocumentView>) -> UIViewControllerType {
        
        let controller = PDFPageViewController( document: document )
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<PDFDocumentView>) {
    
        uiViewController.currentPageIndex = pageSelected
    }
    
}

