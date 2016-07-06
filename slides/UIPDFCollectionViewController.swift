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
    private var _canBecomeFocused:Bool = true
    
    override weak var preferredFocusedView: UIView? {
        
        return ( _canBecomeFocused ) ? buttons[_preferredFocusedViewIndex] : nil
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

    override func didMoveToSuperview() {

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

        print( "PageView.canBecomeFocused:" );
        
        return true
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
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
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
    
    
    func showSlide(at index:UInt) {
        if let doc = self.doc {
            
            let page = doc.pageAtIndex(Int(index+1))
            
            let vectorImage = OHVectorImage(PDFPage: page)
            
            self.pageImageView.image = vectorImage.renderAtSize(pageImageView.frame.size)
            
        }

    }
    
    // MARK: PLAY/PAUSE SLIDES
    
    private var _playPauseSlideShow:Disposable?
    private var _indexPathForPreferredFocusedView:NSIndexPath?
    
    private func playPauseSlideShow() {

        guard _playPauseSlideShow == nil else {
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
            .doOnCompleted{
                self._playPauseSlideShow?.dispose()
                self._playPauseSlideShow = nil
            }
    
        _playPauseSlideShow = playPauseSubject
            .filter{ (press:UIPress) -> Bool in
                return press.type == .PlayPause
            }
            .flatMap{ (_:UIPress) -> Observable<Int> in
                return playSlides
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
    
    override public func updateViewConstraints() {
        
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
        
            cell.box.image = vectorImage.renderAtSize(cell.frame.size)
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
        playPauseSlideShow()
        
        if let press = presses.first {
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