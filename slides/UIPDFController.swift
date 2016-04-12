//
//  UIPDFCollectionViewController.swift
//  slides
//
//  Created by softphone on 01/04/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import Foundation
import SnapKit

class UIPDFPageCell : UICollectionViewCell {
    
    lazy var box:UIImageView = UIImageView()
    
    
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
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
        
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
    
    @IBOutlet weak var pageImageView: UIImageView!
    var doc:OHPDFDocument!
    
    let layoutAttrs = (  cellSize: CGSizeMake(200,300),
                         numCols: 1,
                         minSpacingForCell : CGFloat(20.0),
                         minSpacingForLine: CGFloat(50.0) )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("rx1", ofType: "pdf")
        
        let url = NSURL(fileURLWithPath: path!)
        
        doc = OHPDFDocument(URL: url)
        
        self.view.setNeedsFocusUpdate()
        self.view.updateFocusIfNeeded()
        
    }

    
    override func updateViewConstraints() {
        
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
        //print("sizeForItemAtIndexPath")
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

    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets ;
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
    
        if let i = context.nextFocusedIndexPath {

            let page = doc.pageAtIndex(i.row+1)
            
            let vectorImage = OHVectorImage(PDFPage: page)
            
            self.pageImageView.image = vectorImage.renderAtSize(pageImageView.frame.size)
            
        }
    }
    
    //func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)

    
// MARK: <UICollectionViewDataSource>
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print( "page # \(doc.pagesCount)")
        return doc.pagesCount
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("slide", forIndexPath:indexPath) as! UIPDFPageCell
        
        let page = doc.pageAtIndex(indexPath.row+1)
        
        let vectorImage = OHVectorImage(PDFPage: page)
        
        cell.box.image = vectorImage.renderAtSize(cell.frame.size)
        
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