//
//  UIPDFCollectionViewController.swift
//  slides
//
//  Created by softphone on 01/04/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift

class UIPDFPageCell : UICollectionViewCell {
    
    lazy var box:UIImageView = UIImageView()
    
    private var gestureSubscription:Disposable?
    

    private func initialize() {
    
        self.addSubview(box)
        
         box.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
         }
        
        self.layoutIfNeeded()
        self.layoutSubviews()
        self.setNeedsDisplay()
        
        
        //self.box.adjustsImageWhenAncestorFocused = true
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: nil)

        gestureSubscription = swipeDownRecognizer.rx_event.subscribeNext { (event:UIGestureRecognizer) in
            
            print( "SWIPE DOWN" )
        }

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
        
    }

    deinit {
        
        gestureSubscription?.dispose()
    }
    
 
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if (self.focused)
        {
            self.box.adjustsImageWhenAncestorFocused = true
        }
        else
        {
            self.box.adjustsImageWhenAncestorFocused = false
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    
}


class UIPDFCollectionViewController :  UIViewController, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
 
    
    @IBOutlet weak var pagesView: UICollectionView!
    
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var pageImageView: UIImageView!
    
    private var doc:OHPDFDocument?
    
    var documentLocation:NSURL? {
        didSet {
            doc = OHPDFDocument(URL: documentLocation)
            if( pagesView != nil ) {
                pagesView.reloadData()    
            }
        }
    }
    
    let layoutAttrs = (  cellSize: CGSizeMake(200,300),
                         numCols: 1,
                         minSpacingForCell : CGFloat(20.0),
                         minSpacingForLine: CGFloat(50.0) )
    
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        do {
            let documentDirectoryURL =  try NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)

            //let path = NSBundle.mainBundle().pathForResource("rx1", ofType: "pdf")
            
            //let url = NSURL(fileURLWithPath: path!)
            
            let url = NSURL(string: "presentation.pdf", relativeToURL: documentDirectoryURL)
            
            doc = OHPDFDocument(URL: url)
        }
        catch {
           // Show error on page
        }
        */
        pageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.setNeedsFocusUpdate()
        self.view.updateFocusIfNeeded()
        

        
    }

    override func updateViewConstraints() {
        
        pageImageView.snp_updateConstraints { (make) in
            
            let delta = pageView.frame.width * 0.30
            let newWidth = pageView.frame.width - delta
            
            make.width.equalTo(newWidth).priorityRequired()
        }
        
        pagesView.snp_updateConstraints { (make) -> Void in
                let _ = view.frame
            
                let w = CGFloat(layoutAttrs.numCols) * CGFloat(layoutAttrs.cellSize.width + layoutAttrs.minSpacingForCell )
                make.width.equalTo( w ).priorityHigh()
        }
        
        super.updateViewConstraints()
    }


// MARK: <UICollectionViewDelegateFlowLayout>

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return layoutAttrs.cellSize //use height whatever you wants.
    }

    // Space between item on different row
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return layoutAttrs.minSpacingForLine
    }
    
    // Space between item on the same row
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return layoutAttrs.minSpacingForCell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    
    
// MARK: <UICollectionViewDelegate>
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        print( "canFocusItemAtIndexPath(\(indexPath.row))" )
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
    {
    
        if let doc = self.doc, let i = context.nextFocusedIndexPath {

            let page = doc.pageAtIndex(i.row+1)
            
            let vectorImage = OHVectorImage(PDFPage: page)
            
            self.pageImageView.image = vectorImage.renderAtSize(pageImageView.frame.size)
            
        }
    }
    
    //func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)

    
// MARK: <UICollectionViewDataSource>
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print( "page # \(doc.pagesCount)")
        guard let doc = self.doc else {
            return 0
        }
        return doc.pagesCount
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("slide", forIndexPath:indexPath) as! UIPDFPageCell
        
        if let doc = self.doc {
            let page = doc.pageAtIndex(indexPath.row+1)
        
            let vectorImage = OHVectorImage(PDFPage: page)
        
            cell.box.image = vectorImage.renderAtSize(cell.frame.size)
        }
        return cell;

    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    //override public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    
    //override public func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    //override public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    
    
    
    
}