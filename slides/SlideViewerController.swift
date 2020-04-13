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
import RxSwiftExt

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

//
//  UIPDFPageCell
//
class UIPDFPageCell : UICollectionViewCell {
    
    lazy var box:UIImageView = UIImageView()
    
    fileprivate func initialize() {
    
        //box.layer.borderColor = UIColor.black.cgColor
        //box.layer.borderWidth = 2

        self.addSubview(box)
        
         box.snp.makeConstraints { make in
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
 
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (self.isFocused)
        {
            self.box.adjustsImageWhenAncestorFocused = true
        }
        else
        {
            self.box.adjustsImageWhenAncestorFocused = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}


//
//  MARK: UIPDFCollectionViewController
//
class UIPDFCollectionViewController :  UIViewController, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, NameDescribable {
    
    static let storyboardIdentifier = "UIPDFCollectionViewController"
    
    @IBOutlet weak var pagesView: ThumbnailsView!
    
    @IBOutlet weak var settingsBar: SettingsBarView!
    @IBOutlet weak var pageView: PageView!
    
    
    fileprivate var doc:OHPDFDocument?

    fileprivate var pressesSubject = PublishSubject<UIPress>()
    fileprivate let disposeBag = DisposeBag()

    @objc var fullpage : Bool = false {
             
        didSet {
             if fullpage {
                self.hideThumbnails()
             }
             else {
                self.showThumbnails()
             }
             self.view.setNeedsUpdateConstraints()
         }
    }
    
    var documentInfo:DocumentInfo? {
        didSet {
            if let location = documentInfo?.location {
                doc = OHPDFDocument(url: location)
                if( pagesView != nil ) {
                    pagesView.reloadData()
                }
            }
        }
    }
    
    func showSlide(at index:UInt) {
        if let doc = self.doc {
            
            let page = doc.page(at: Int(index+1))
            
            let vectorImage = OHVectorImage(pdfPage: page)
            
            let fitSize = vectorImage?.sizeThatFits(pageView.pageImageView.frame.size)
            self.pageView.pageImageView.image = vectorImage?.render(at: fitSize!)
            
        }

    }
    
    // MARK: PLAY/PAUSE SLIDES
    
    
    fileprivate var _playPauseSlideShow:Disposable?
    fileprivate var _indexPathForPreferredFocusedView:IndexPath?

    fileprivate var currentPageIndex:Int {
        get {
            guard let index = self._indexPathForPreferredFocusedView else {
                return 1
            }
            return index.row
        }
    }
    
    @IBAction func playPauseSlideShow() {

        guard _playPauseSlideShow == nil else {
            self._playPauseSlideShow?.dispose()
            self._playPauseSlideShow = nil
            return
        }

        self.fullpage = true
        
        _playPauseSlideShow = Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance)
            .map({ (index:Int) -> Int in

                guard let prevIndex = self._indexPathForPreferredFocusedView else {
                    return index + 1
                }
                return prevIndex.row + 1
                
            })
            .takeWhile({ (slide:Int) -> Bool in
                return slide < self.doc?.pagesCount
            })
            .takeUntil( pressesSubject.filter { (press:UIPress) -> Bool in
                press.type != UIPress.PressType.playPause
            })
            .do( onCompleted:{
                self._playPauseSlideShow?.dispose()
                self._playPauseSlideShow = nil
            })
            .subscribe( onNext: { (slide:Int) in
                
                let i = IndexPath(row: slide, section: 0)
                
                self.showSlide(at: UInt(i.row)) ; self._indexPathForPreferredFocusedView = i

                self.pagesView.selectItem(at: i, animated: false, scrollPosition: UICollectionView.ScrollPosition())
                //self.pagesView.setNeedsFocusUpdate()
                //self.pagesView.updateFocusIfNeeded()
            })
        
    }
    
    // MARK: - Pointer Management
    // MARK: -
    
    fileprivate func setupPointer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePointerOnTap) )
        tap.numberOfTapsRequired = 1
        pageView.addGestureRecognizer(tap)
   }
    
    @IBAction func togglePointerOnTap(_ sender: UITapGestureRecognizer) {
        pageView.showPointer = !pageView.showPointer

    }

    // MARK: - SettingsBar Management
    // MARK: -

    fileprivate func setupSettingsBar() {
        
        self.settingsBar.items?.forEach({ (item) in
            item.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize:  20)], for: .normal)
        })
        
        let rxFavoriteStoreDeferred = Completable.deferred { () -> PrimitiveSequence<CompletableTrait, Never> in
            
            print( "\(self.typeName) save to favorite \(!self.fullpage)")
            
            guard let documentInfo = self.documentInfo else {
                return Completable.empty()
            }
                
            return rxFavoriteStore(data: documentInfo)
                .do( onCompleted: {

                    print("\(self.typeName) Favorite stored")

                    self.setNeedsFocusUpdate()
                })
                
        }
        
        let rxToggleFullPageDeferred = Completable.deferred { () -> PrimitiveSequence<CompletableTrait, Never> in
            
            print( "\(self.typeName) fullpage \(!self.fullpage)")
            
            self.fullpage = !self.fullpage
            
            self.setNeedsFocusUpdate()

            return Completable.empty()
        }
        
        self.settingsBar.rx_didPressItem
            .observeOn(MainScheduler.asyncInstance)
            .flatMap { (item ) -> Completable in
                switch item {
                case .FULL_SCREEN: // toggle fullscreen
                    return rxToggleFullPageDeferred;
                case .ADD_TO_FAVORITE:
                    return rxFavoriteStoreDeferred;
                default:
                    return Completable.empty()
                }
            }
            .subscribe(
                onCompleted:{
                    print( "==> COMPLETED" )
                })
            .disposed(by: disposeBag)
    
    }
    
    // MARK: Setup Manual Next Prev page
    
    fileprivate func setupNextPrev() {
   
        let fullpageObserver =
            self.rx.observe(Bool.self, "fullpage")
            .distinctUntilChanged{ (lhs:Bool?, rhs:Bool?) -> Bool in
                return lhs! == rhs!
            }
            .map { (value:Bool?) -> Bool in
                print( "FULLPAGE \(value!)" )
                return value!
            }
        
        pressesSubject
            .filter { (press:UIPress) -> Bool in
                return press.type == .leftArrow || press.type == .rightArrow
            }
            .pausable( fullpageObserver )
            .subscribe( onNext: { (press:UIPress) in
                
                guard let pagesCount = self.doc?.pagesCount else {
                    return
                }
                
                var slide = 0
                
                if let index = self._indexPathForPreferredFocusedView  {
                    slide = index.row
                }
                
                switch press.type {
                case .leftArrow where slide == 0:
                    print( "REACH TOP" )
                    return
                case .rightArrow where slide == pagesCount - 1:
                    print( "REACH BOTTOM" )
                    return
                case .leftArrow:
                    slide = slide - 1;
                    print( "PREV SLIDE FROM OBSERVABLE" )
                    break
                case .rightArrow:
                    slide = slide + 1;
                    print( "NEXT SLIDE FROM OBSERVABLE" )
                    break
                default:
                    break
                }
                
                let i = IndexPath(row: slide, section: 0)

                self.showSlide(at: UInt(i.row)) ; self._indexPathForPreferredFocusedView = i
                
                self.pagesView.selectItem(at: i, animated: false, scrollPosition: UICollectionView.ScrollPosition())


            }).disposed(by: disposeBag)
    }
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pagesView.backgroundColor = UIColor.clear
        
        //let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(playPauseSlideShow))
        //playPauseTap.allowedPressTypes = [UIPressType.PlayPause.rawValue]
        //view.addGestureRecognizer(playPauseTap)
        
        self.setupSettingsBar()
        self.setupPointer()
        self.setupNextPrev()
        
        pageView.pageImageView.translatesAutoresizingMaskIntoConstraints = false
 
//        pageView.becomeFocusedPredicate = {
//
//            return !self.settingsBar.isFocused
//        }
        
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showSlide(at: 0)
    }
    

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return layoutAttrs.cellSize //use height whatever you wants.
    }

    // Space between item on different row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return layoutAttrs.minSpacingForLine
    }
    
    // Space between item on the same row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return layoutAttrs.minSpacingForCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    
    
// MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print( "\(typeName).didSelectItemAtIndexPath: \(indexPath)" )
    }
    
// MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let doc = self.doc else {
            return 0
        }
        return doc.pagesCount
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "slide", for:indexPath) as! UIPDFPageCell
        
        if let doc = self.doc {
            
            let page = doc.page(at: indexPath.row+1)
        
            let vectorImage = OHVectorImage(pdfPage: page)
            
            let fitSize = vectorImage?.sizeThatFits(cell.frame.size)
            
            cell.box.image = vectorImage?.render(at: fitSize!)
        }
        return cell;

    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    //override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    
    //override func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    //override func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)


// MARK: - Focus Engine
// MARK: -

    
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {

        print( "\(typeName).preferredFocusEnvironments")
        return ( self.fullpage ) ?
            [ pageView, settingsBar] :
        super.preferredFocusEnvironments

    }
    
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        
        print( "\(typeName).shouldUpdateFocus" );
        if( context.nextFocusedView == self.pageView ) {
            self.settingsBar.resetSelection()
        }
        return true
    }
    
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        print( "\(typeName).didUpdateFocusInContext: focused: \(type(of: context.nextFocusedView))" );

    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
                        with coordinator: UIFocusAnimationCoordinator)
    {
        print("\(typeName).didUpdateFocusInContext")
       
        if let i = context.nextFocusedIndexPath {
            self.showSlide(at: UInt(i.row)) ; _indexPathForPreferredFocusedView = i
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        print( "\(typeName).canFocusItemAtIndexPath(\(indexPath.row))" )
        return true
    }
    
    
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        print("\(typeName).indexPathForPreferredFocusedViewInCollectionView: \(String(describing: _indexPathForPreferredFocusedView))")
        
        // Return index path for selected show that you will be playing
        return _indexPathForPreferredFocusedView
    }
    
    // MARK: Presses Handling
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("\(typeName).pressesBegan")

        if let press = presses.first {
            
            switch press.type {
            case .playPause:
                playPauseSlideShow()
                break
            default:
                pressesSubject.on( .next(press) )
                break
            }

        }

        super.pressesBegan(presses, with: event)
        
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("\(typeName).pressesEnded")
        super.pressesEnded(presses, with: event)
    }
    
    
    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesChanged(presses, with: event)
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesCancelled(presses, with: event)
    }
    
}
