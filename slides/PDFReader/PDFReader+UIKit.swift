//
//  PDFView+UIKit.swift
//  Samples
//
//  Created by Bartolomeo Sorrentino on 06/03/2020.
//  Copyright © 2020 mytrus. All rights reserved.
//

import SwiftUI
import Combine


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
        
    override func viewWillAppear(_ animated:Bool) {
        print( "viewWillAppear")
        updateCurrentPage()
        super.viewWillAppear(animated)
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

