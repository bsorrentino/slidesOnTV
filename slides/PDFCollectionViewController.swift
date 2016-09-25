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


// MARK: Pointer View

func setupPointerView() -> UIView {
    //let pointer = UIImageView( image: UIImage(named: "pointer") )

    let pointer:UIView = UIView( frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    pointer.backgroundColor = UIColor.magentaColor()
    pointer.userInteractionEnabled = false
    
    pointer.layer.cornerRadius = 10.0
    
    // border
    pointer.layer.borderColor = UIColor.lightGrayColor().CGColor
    pointer.layer.borderWidth = 1.5
    
    // drop shadow
    pointer.layer.shadowColor = UIColor.blackColor().CGColor
    pointer.layer.shadowOpacity = 0.8
    pointer.layer.shadowRadius = 3.0
    pointer.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    
    return pointer
}

//
//  MARK: UIPageView
//
class UIPageView : UIView {

    let pointer:UIView = setupPointerView()

    let settingsBar = SettingsBarView()
    
    
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
        let result =  !self.settingsBar.canBecomeFocused() || _preferredFocusedView==nil

        print( "PageView.canBecomeFocused: \(result)" );
        
        return result
    }
    
    /// Asks whether the system should allow a focus update to occur.
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        
        print( "PageView.shouldUpdateFocusInContext:" )
        
        return true;
        
    }
    
    /// Called when the screen’s focusedView has been updated to a new view. Use the animation coordinator to schedule focus-related animations in response to the update.
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
    {
        print( "PageView.didUpdateFocusInContext: focused: \(self.focused)" );
        
        
        if( !self.settingsBar.canBecomeFocused() && self._preferredFocusedView != nil ) {
            
            coordinator.addCoordinatedAnimations({
                
                UIView.animateWithDuration(0.5, animations: {
                    
                    self.settingsBar.hideAnimated()
                    
                })
            }){
                self.layer.borderWidth = 0
                
                self._preferredFocusedView = nil
                self.settingsBar.canBecomeFocused(true)
                
            }
            
        }
        else if( self.focused ) {
            
            coordinator.addCoordinatedAnimations({
            
                self.settingsBar.showAnimated()

            }){
                self.layer.borderWidth = 2
                
                self.layer.borderColor = UIColor.darkGrayColor().CGColor
                
                self._preferredFocusedView = self.settingsBar
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
                
            }
            
        }
        
    }

    // MARK: Touch Handling

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        let locationInView = firstTouch.locationInView(firstTouch.view)
        
        addSubview(pointer)
            
        var f = pointer.frame
        f.origin = locationInView
        
        pointer.frame = f
    }
    
    override func  touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touchesMoved ")
    
        guard let firstTouch = touches.first else { return }
        
        let locationInView = firstTouch.locationInView(firstTouch.view)

        var f = pointer.frame
        f.origin = locationInView
        
        pointer.frame = f
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touchesEnded ")
        pointer.removeFromSuperview()
    
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touchesCancelled ")
        pointer.removeFromSuperview()
    
    }
    
    
}


//
//  MARK: UIPDFCollectionViewController
//
public class UIPDFCollectionViewController :  UIViewController, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
 
    public static let storyboardIdentifier = "UIPDFCollectionViewController"
    
    @IBOutlet weak var pagesView: UICollectionView!
    
    @IBOutlet weak var pageView: UIPageView!
    @IBOutlet weak var pageImageView: UIImageView!
    
    private var doc:OHPDFDocument?

    private var playPauseSubject = PublishSubject<UIPress>()
    private let disposeBag = DisposeBag()

    let layoutAttrs = (  cellSize: CGSizeMake(300,300),
                         numCols: 1,
                         minSpacingForCell : CGFloat(25.0),
                         minSpacingForLine: CGFloat(50.0) )
    
        
    var documentLocation:NSURL? {
        didSet {
            doc = OHPDFDocument(URL: documentLocation)
            if( pagesView != nil ) {
                pagesView.reloadData()    
            }
        }
    }
    
    func showSlide(at index:UInt) {
        if let doc = self.doc {
            
            let page = doc.pageAtIndex(Int(index+1))
            
            let vectorImage = OHVectorImage(PDFPage: page)
            
            let fitSize = vectorImage.sizeThatFits(pageImageView.frame.size)
            self.pageImageView.image = vectorImage.renderAtSize(fitSize)
            
        }

    }
    
    // MARK: PLAY/PAUSE SLIDES
    
    private var _playPauseSlideShow:Disposable?
    private var _indexPathForPreferredFocusedView:NSIndexPath?
    
    
    private func showPagesView(originalWidth:CGFloat) {
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            var page_frame = self.pageView.frame
            page_frame.origin.x += originalWidth
            self.pageView.frame = page_frame

            
            var pages_frame = self.pagesView.frame
            pages_frame.size.width = originalWidth
            self.pagesView.frame = pages_frame
            
            
        } ) { (completion:Bool) in
            
            if( completion ) {
                self.fullpage = false
            }
        
        }

        
    }
    
    private func hidePagesView() -> CGFloat {
        
        let result = self.pagesView.frame.size.width
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut , animations: {
            
            
            var pages_frame = self.pagesView.frame
            pages_frame.size.width = 0
            self.pagesView.frame = pages_frame
            
            var page_frame = self.pageView.frame
            page_frame.origin.x -= result
            self.pageView.frame = page_frame


        }) { (completion:Bool) in
            
            if( completion ) {
                self.fullpage = true
            }

        }
    
        return result
    }
    
    private func playPauseSlideShow() {

        guard _playPauseSlideShow == nil else {
            // ALREADY IN PLAY
            return
        }
        
        let playSlides = Observable<Int>.interval(3, scheduler: MainScheduler.instance)
            .map({ (index:Int) -> Int in

                guard let prevIndex = self._indexPathForPreferredFocusedView else {
                    return index + 1
                }
                return prevIndex.row + 1
                
            })
            .takeWhile({ (slide:Int) -> Bool in
                return slide < self.doc?.pagesCount
            })
            .takeUntil( playPauseSubject )
    
        
        let originalWidth =  hidePagesView()
        
        _playPauseSlideShow = playPauseSubject
            .filter{ (press:UIPress) -> Bool in
                return press.type == .PlayPause
            }
            .flatMap{ (_:UIPress) -> Observable<Int> in
                
                return playSlides.doOnCompleted{

                    self.showPagesView(originalWidth)
                    
                    self._playPauseSlideShow?.dispose()
                    self._playPauseSlideShow = nil
                    
                }

            }
            .subscribeNext { (slide:Int) in
                
                let i = NSIndexPath(forRow: slide, inSection: 0)
                self._indexPathForPreferredFocusedView = i
                self.pagesView.selectItemAtIndexPath(i, animated: false, scrollPosition: .None)
                self.pagesView.setNeedsFocusUpdate()
                self.pagesView.updateFocusIfNeeded()
            }
        
    }
    
    // MARK: view lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        pageImageView.translatesAutoresizingMaskIntoConstraints = false
 
        self.view.setNeedsFocusUpdate()
        self.view.updateFocusIfNeeded()
 
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showSlide(at: 0)
    }
    

// MARK: <UICollectionViewDelegateFlowLayout>

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return layoutAttrs.cellSize //use height whatever you wants.
    }

    // Space between item on different row
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return layoutAttrs.minSpacingForLine
    }
    
    // Space between item on the same row
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return layoutAttrs.minSpacingForCell
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    
    
// MARK: <UICollectionViewDelegate>
    
    //func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)

    
// MARK: <UICollectionViewDataSource>
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let doc = self.doc else {
            return 0
        }
        return doc.pagesCount
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("slide", forIndexPath:indexPath) as! UIPDFPageCell
        
        if let doc = self.doc {
            
            let page = doc.pageAtIndex(indexPath.row+1)
        
            let vectorImage = OHVectorImage(PDFPage: page)
            
            let fitSize = vectorImage.sizeThatFits(cell.frame.size)
            
            cell.box.image = vectorImage.renderAtSize(fitSize)
        }
        return cell;

    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    //override public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    
    //override public func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    //override public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
 
// MARK: <Focus Engine>
 
    public func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        print("didUpdateFocusInContext:\(context.nextFocusedIndexPath)")
       
        if let i = context.nextFocusedIndexPath {
            self.showSlide(at: UInt(i.row))
            _indexPathForPreferredFocusedView = i
            
        }
    }
    
    public func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        print( "canFocusItemAtIndexPath(\(indexPath.row))" )
        return true
    }
    
    
    public func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
        print("indexPathForPreferredFocusedViewInCollectionView")
        // Return index path for selected show that you will be playing
        return _indexPathForPreferredFocusedView
    }
    
    
    override public func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
    }
    
    // MARK: Presses Handling
    
    override public func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        print("pressesBegan")
        
        
        if let press = presses.first {
            
            if press.type == .PlayPause {
                playPauseSlideShow( )
            }

            playPauseSubject.on( .Next(press) )
        }
    }
    
    override public func pressesChanged(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        if let press = presses.first {
            playPauseSubject.on( .Next(press) )
        }
    }
    
    override public func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    }
    
    override public func pressesCancelled(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    }
    
}
