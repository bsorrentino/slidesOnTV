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
import RxCocoa

//
//  UIPDFPageCell
//
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



class UISettingsBarView : UIView {
    
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
    
    override func didMoveToSuperview() {
        setupView()
    }

    override func updateConstraints() {
        
        super.updateConstraints()
    }

// MARK: Focus Management
    
    private var _preferredFocusedViewIndex:Int = 0
    
    internal override var focused: Bool {
        return buttons.reduce(false, combine: { (status, button) -> Bool in
            
            return status || button.focused;
        })
    }
    
    override weak var preferredFocusedView: UIView? {
        
        return buttons[_preferredFocusedViewIndex]
    }
   
    
    override func canBecomeFocused() -> Bool {
        
        let result = ( _preferredFocusedViewIndex >= 0 && _preferredFocusedViewIndex < buttons.count )
        
        print( "UISettingsBarView.canBecomeFocused:\(result)" );
        
        return result
    }
    
    
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        
        let result = !( (context.focusHeading == .Left && _preferredFocusedViewIndex == 0) || (context.focusHeading == .Right && _preferredFocusedViewIndex == buttons.count - 1 ) || context.focusHeading == .Up || context.focusHeading == .Down)
 
        print( "UISettingsBarView.shouldUpdateFocusInContext \(result)" )
        
        return result
        
    }

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        print( "UISettingsBarView.didUpdateFocusInContext:\(context.focusHeading)" );
        
        switch( context.focusHeading ) {
        case UIFocusHeading.Left:
            
            _preferredFocusedViewIndex = _preferredFocusedViewIndex - 1
            break
        case UIFocusHeading.Right:
            _preferredFocusedViewIndex = _preferredFocusedViewIndex + 1
            break
        default:
            break
        }
        
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
       
        
    }
    

}

//
//  UIPageView
//
class UIPageView : UIView {
    
    let settingsBar = UISettingsBarView()
 

    override func didMoveToSuperview() {
        
        self.addSubview(settingsBar)
       
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
    }
    // MARK: Focus Management
    
    private var _preferredFocusedView:UIView?
    
    override weak var preferredFocusedView: UIView? {
        
        guard let pfv = _preferredFocusedView else {
            return super.preferredFocusedView
        }
        return pfv
    }
    
    override func canBecomeFocused() -> Bool {
        let result =  _preferredFocusedView==nil


        print( "PageView.canBecomeFocused:\(result)" );
        
        return result
    }
    
    /// Asks whether the system should allow a focus update to occur.
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        
        let result = true //!settingsBar.focused
/*
         if let zoomIn = settingsBar.zoomIn  {
         
         if  zoomIn.focused  {
         print( "zoomIn.focused");
         return
         }
         }
*/
        print( "PageView.shouldUpdateFocusInContext \(result)" )
        
        return result;
        
    }
    
    /// Called when the screen’s focusedView has been updated to a new view. Use the animation coordinator to schedule focus-related animations in response to the update.
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
    {
        print( "PageView.didUpdateFocusInContext" );
        
        if( self.focused ) {
            
            coordinator.addCoordinatedAnimations({
                
                UIView.animateWithDuration(0.5, animations: {
                    
                    var f = self.settingsBar.frame
                    f.size.height = 80
                    self.settingsBar.frame = f
                    
                    self.settingsBar.subviews.forEach({ (v:UIView) in
                        v.alpha = 1.0
                    })
                    
                    //self.setNeedsUpdateConstraints()
                })
            }){
                self.layer.borderWidth = 2
                
                self.layer.borderColor = UIColor.darkGrayColor().CGColor
                
                self._preferredFocusedView = self.settingsBar
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
                
                
            }
            
        }
        else if( !self.settingsBar.focused && self._preferredFocusedView != nil ){
            coordinator.addCoordinatedAnimations({
                
                UIView.animateWithDuration(0.5, animations: {
                    
                    self.settingsBar.subviews.forEach({ (v:UIView) in
                        v.alpha = 0.0
                    })
                    
                    var f = self.settingsBar.frame
                    f.size.height = 1.0
                    self.settingsBar.frame = f
                    
                    //self.setNeedsUpdateConstraints()
                    
                    
                })
            }){
                self.layer.borderWidth = 0
                
                self._preferredFocusedView = nil
                
            }
            
        }
        
    }
    
}


//
//  UIPDFCollectionViewController
//
class UIPDFCollectionViewController :  UIViewController, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
 
    
    @IBOutlet weak var pagesView: UICollectionView!
    
    @IBOutlet weak var pageView: UIPageView!
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
    
    let layoutAttrs = (  cellSize: CGSizeMake(300,300),
                         numCols: 1,
                         minSpacingForCell : CGFloat(25.0),
                         minSpacingForLine: CGFloat(50.0) )
    
    // MARK:
    
    @IBAction func swipeDown(sender:UISwipeGestureRecognizer) {
        
        print( "swipe down");
    }
    
    func showSlide(at index:UInt) {
        if let doc = self.doc {
            
            let page = doc.pageAtIndex(Int(index+1))
            
            let vectorImage = OHVectorImage(PDFPage: page)
            
            self.pageImageView.image = vectorImage.renderAtSize(pageImageView.frame.size)
            
        }

    }
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageImageView.translatesAutoresizingMaskIntoConstraints = false
 
        self.view.setNeedsFocusUpdate()
        self.view.updateFocusIfNeeded()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown(_:)))
        gesture.direction = .Down
        
        pageView.addGestureRecognizer(gesture)
        
        

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showSlide(at: 0)
    }
    
    override func updateViewConstraints() {
        
        
        let w = CGFloat(layoutAttrs.numCols) * CGFloat(layoutAttrs.cellSize.width + layoutAttrs.minSpacingForCell )
        let pageViewWidth = view.frame.size.width - w

        pageView.snp_updateConstraints { (make) -> Void in
            
            make.width.equalTo( pageViewWidth ).priorityRequired()
        }
        
        pagesView.snp_updateConstraints { (make) -> Void in
            
                make.width.equalTo( w ).priorityHigh()
        }
        
        pageImageView.snp_updateConstraints { (make) in
            
            let delta = pageViewWidth * 0.30
            let newWidth = pageViewWidth - delta
            
            make.width.equalTo(newWidth).priorityRequired()
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
 
// MARK: <Focus Engine>
 
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
    {
        
        if let i = context.nextFocusedIndexPath {
            
            self.showSlide(at: UInt(i.row))
            
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        print( "UIPDFCollectionViewController.canFocusItemAtIndexPath(\(indexPath.row))" )
        return true
    }
    
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        
        print( "UIPDFCollectionViewController.didUpdateFocusInContext" )
    }
    
    
}