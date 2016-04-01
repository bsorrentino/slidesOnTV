//
//  UIPDFCollectionViewController.swift
//  slides
//
//  Created by softphone on 01/04/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import Foundation

class UIPDFPageCell : UICollectionViewCell {
    
}


class UIPDFCollectionViewController : UICollectionViewController {
 
    var doc:OHPDFDocument!
    
    override func viewDidLoad() {
        let path = NSBundle.mainBundle().pathForResource("rx1", ofType: "pdf")
        
        let url = NSURL(fileURLWithPath: path!)
        
        doc = OHPDFDocument(URL: url)
        
        
    }
    
// MARK: <UICollectionViewDataSource>
    
    override internal func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doc.pagesCount
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    override internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("slide", forIndexPath:indexPath)
        
        
        return cell;

    }
    
    override internal func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    //override public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    
    //override public func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    //override public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    
// MARK: <UICollectionViewDelegate>
    
    
    
}