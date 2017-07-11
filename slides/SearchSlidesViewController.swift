//
//  SlideSearchViewController.swift
//  slides
//
//  Created by softphone on 11/04/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa
import TVOSToast

class Scheduler {
    
    // implicit lazy
    static var backgroundWork: ImmediateSchedulerType = {
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        
        return OperationQueueScheduler(operationQueue: operationQueue)
        
    }()
}

class SearchSlideCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties

    static let reuseIdentifier = "SearchSlideCell"

    @IBOutlet weak var thumbnail: UIImageView?
    
    fileprivate lazy var loadingView:UAProgressView? = self.initLoadingView()
    
    fileprivate var _representedDataItem: Slideshow?
    var representedDataItem: Slideshow?  {
        
        set {
            
            self._representedDataItem = newValue
            
            guard let item = newValue else {
                return;
            }
            
            if let thumbnail = item[DocumentField.ThumbnailXL]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                
                let s = "http:\(thumbnail)"
                
                if let url = URL(string: s ) {
                    
                    self.loadImageUrl(url, backgroundWorkScheduler: Scheduler.backgroundWork)
                }
            }

        }
        get {
            return self._representedDataItem
        }
    }
    
    var disposeBag: DisposeBag?
    
    func loadImageUrl( _ imageUrl:URL, backgroundWorkScheduler:ImmediateSchedulerType )  {
            let disposeBag = DisposeBag()
            
        URLSession.shared.rx.data( request: URLRequest(url: imageUrl))
                .debug("image request")
                .flatMap({ (imageData) -> Observable<UIImage> in
                    return Observable.just(imageData)
                        .observeOn(backgroundWorkScheduler)
                        .debug( "map data to image")
                        .map { data in
                            guard let image = UIImage(data: data) else {
                                // some error
                                throw NSError(  domain: "SearchSlidesViewController",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Decoding image error"])
                            }
                            return image/*.forceLazyImageDecompression()*/
                            
                    }
                })
                .observeOn(MainScheduler.instance)
                .subscribe(
                    onNext: { (image) in
                    self.thumbnail?.image = image
                    },
                    onError: { (e) in
                        print( "ERROR: \(e)")
                    }
                )
                //.trackActivity(self.loadingImage)
                .addDisposableTo(disposeBag)
            
                self.disposeBag = disposeBag
    }
    
    // MARK: Progress
    var lastUpdatedProgress:Float = 0.0
    
    func initLoadingView() -> UAProgressView? {
        
        if let thumbnail = self.thumbnail {
            
            let size = CGSize(width: 250, height: 250)
            let center = CGPoint( x: thumbnail.center.x - size.width/2, y: thumbnail.center.y - size.height/2 )
            
            let frame = CGRect(x: center.x, y: center.y, width: size.width,height: size.height)
            
            let circleView =  UAProgressView(frame: frame)
            circleView.borderWidth = 10
            circleView.lineWidth = 5
            circleView.setFillAlpha(0.5)
            
            let label = UILabel(frame:CGRect(x: 0, y: 0, width: 120.0, height: 40.0))
            label.textAlignment = .center
            label.isUserInteractionEnabled = false; // Allows tap to pass through to the progress view.
            label.font = UIFont.boldSystemFont(ofSize: 30.0)
            label.textColor = UIColor.white //circleView.tintColor
            
            circleView.centralView = label;
            
            
            circleView.progressChangedBlock = { (progressView:UAProgressView?, progress:CGFloat) in
                
                if let label = progressView?.centralView as? UILabel {
                    print( "progressChangedBlock \(progress)")

                    label.text = String( format:"%2.0f%%", progress*100 )
                }
            }
            
            return circleView
        }
        
        
        return nil;
        
    }

    
    func showProgress() {
    
        if let loadingView = self.loadingView {
            self.addSubview(loadingView)
        }
    }
    
    func setProgress( _ progress:Float) {
        
        if let loadingView = self.loadingView {
            
            //let p = Int32( progress/10 ) * 10
            
            if lastUpdatedProgress < progress && progress <= 100.0 {
                print( "progress \(progress)")
                
                loadingView.setProgress(CGFloat(progress), animated: true)
                lastUpdatedProgress = progress
            }
            
        }
    }
    
    func resetProgress() {
        
        if let loadingView = self.loadingView {
            
            loadingView.progress = 0
            lastUpdatedProgress = 0
            loadingView.removeFromSuperview()
        }
    }
    
    // MARK: Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // These properties are also exposed in Interface Builder.
        thumbnail?.adjustsImageWhenAncestorFocused = true
        thumbnail?.clipsToBounds = false

    }

    // MARK: UICollectionReusableView
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil

    }
    
    // MARK: UIFocusEnvironment
    
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator )
    {
    }
}

typealias DocumentInfo = ( location:URL, id:String, title:String )

class DetailView : UIView {
    
    var originalHeight:CGFloat = 0.0
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var updatedLabel: UILabel!
    static func loadFromNib() -> DetailView {
        
        let nibViews = Bundle.main.loadNibNamed("DetailView", owner: nil, options: nil)
        
        for v in nibViews! {
            if let tog = v as? DetailView {
                return tog
            }
        }
        return DetailView()

    }
    override func awakeFromNib() {
        self.originalHeight = self.frame.size.height
    }
 
    override func updateConstraints() {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        if let superview = appDelegate.window  {
            
            
            self.snp.updateConstraints { (make) in
                
                make.height.equalTo(self.frame.size.height)
                make.width.equalTo(superview)
                make.bottom.equalTo(superview.snp.bottom)//.offset(-offsetFromBottom)
            }
        }
        
        super.updateConstraints()
    }
    
    func addToWindow() -> DetailView {
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let superview = appDelegate.window  {
        
            self.addTo(superview)
        }
        
        return self
    }
    
    func addTo(_ superview: UIView) -> DetailView {
        
        superview.addSubview( self )
        
        return self
    }
    
    func show(_ item:Slideshow?) {
        
        self.alpha = 1.0
        //self.hidden = false
        
        var frame = self.frame
        
        frame.size.height = originalHeight
        
        self.frame = frame
        
        if let item = item {
            
            if let title = item[DocumentField.Title]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                
                self.titleLabel.text = title
            }
            
            if let updated = item[DocumentField.Updated] {
                self.updatedLabel.text = updated
            }
        }
        
        
        setNeedsUpdateConstraints()
    }

    func hide() {
        
        self.alpha = 0.0
        //self.hidden = true
        
        var frame = self.frame
        
        frame.size.height = 0
        
        self.frame = frame
    }
    
}




open class SearchSlidesViewController: UICollectionViewController, UISearchResultsUpdating {
    // MARK: Properties
    
    open static let storyboardIdentifier = "SearchSlidesViewController"
    
    fileprivate var filteredDataItems:[Slideshow] = []
    
    fileprivate lazy var detailView:DetailView = DetailView.loadFromNib()
    
    let disposeBag = DisposeBag()
    
    let searchResultsUpdatingSubject = PublishSubject<String>()
    
    // MARK: DOWNLOAD MANAGEMENT
    
    var downloadDispose:Disposable?
    
    var menuTap:UITapGestureRecognizer?
    
    private func overrideMenuTap( _ enabled:Bool = false ) {
        menuTap = UITapGestureRecognizer(target: self, action: #selector(menuTapped))
        menuTap?.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)]
        menuTap?.isEnabled = enabled
        view.addGestureRecognizer(menuTap!)
        
    }
    
    @IBAction func menuTapped(_ sender: UITapGestureRecognizer) {
        downloadDispose?.dispose()
        downloadDispose = nil
    }
    
    fileprivate func rxDownload( presentation item:Slideshow, showOnCell cell:SearchSlideCollectionViewCell ) {
        
        let toast = TVOSToast(frame: CGRect(x: 0, y: 0, width: 800, height: 80))
        //toast.style.position = TVOSToastPosition.topRight(insets: 0)
        toast.style.position = TVOSToastPosition.top(insets: -10)
        
        toast.hintText =
            TVOSToastHintText(element:
                [ToastElement.stringType("Press the "),
                 ToastElement.remoteButtonType(.MenuWhite),
                 ToastElement.stringType(" button to cancel download")])
        
        
        downloadDispose = rxDownloadFromURL( presentation:item )
        {
            (progress, totalBytesWritten, totalBytesExpectedToWrite) in
            
            cell.setProgress(progress)
            }
            .do(
                onError: { [unowned self] (err) in
                    self.collectionView?.isUserInteractionEnabled = true
                    self.menuTap?.isEnabled = false
                },
                onSubscribe: { [unowned self] in
                    self.collectionView?.isUserInteractionEnabled = false
                    self.menuTap?.isEnabled = true
                    self.presentToast(toast)
                    cell.showProgress()
                },
                onDispose: { [unowned self] in
                    self.collectionView?.isUserInteractionEnabled = true
                    self.menuTap?.isEnabled = false
                    cell.resetProgress()
                }
            )
            .subscribe(onSuccess: { (value:(Slideshow,URL?)) in
                
                let title = item[DocumentField.Title] ?? ""
                let id = item[DocumentField.ID] ?? "unknown" // raise error
                
                self.performSegue(withIdentifier: "showPresentation", sender: DocumentInfo( location:value.1!, id:id, title:title) )
                
            }) { (err) in
                
                print( "error downloading url")
        }

    }
    // MARK: UICollectionViewController Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        guard let bundlePath = Bundle.main.path(forResource: "slideshare", ofType: "plist") else {
            return
        }
        
        guard let credentials = NSDictionary(contentsOfFile: bundlePath ) else {
            return
        }
        
        // Initilaize DetailView
        
        detailView.addToWindow().hide()
        
        overrideMenuTap()
        
        
#if (arch(i386) || arch(x86_64)) && os(tvOS)
    let debounce:RxSwift.RxTimeInterval = 0.5
#else
    let debounce:RxSwift.RxTimeInterval = 2.5
#endif
        
        searchResultsUpdatingSubject
        .filter( { (filter:String) -> Bool in
            let length = Int(filter.characters.count)
            
            print( "count \(length)")
            
            return length > 2
        })
        .distinctUntilChanged()
        .debounce(debounce, scheduler: MainScheduler.instance)
        .debug("slideshareSearch")
        .flatMap( {  (filterString) -> Observable<Data> in
        
            return rxSlideshareSearch(
                        apiKey: credentials["apiKey"]! as! String,
                        sharedSecret: credentials["sharedSecret"] as! String,
                        query: filterString )
        })
        .debug("parse")
        .do( onNext:{ (_) in self.filteredDataItems.removeAll() })
        .flatMap({ (data:Data) -> Observable<Slideshow> in

            let slidehareItemsParser = SlideshareItemsParser()
            
            return slidehareItemsParser.rx_parse(data)
        })
        .debug( "subscribe")
        .filter({ (slide:Slideshow) -> Bool in
            print( "\(slide)" )
            if let format = slide[DocumentField.Format]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                return format.lowercased()=="pdf"
            }
            return true
        })
        .observeOn(MainScheduler.instance)
            .subscribe(
                onNext:{ slide in
            
                    //if let slide = e.element {
                        
                        self.filteredDataItems.append(slide)
                        
                        let title = slide[DocumentField.Title]
                        
                        print( "\(title ?? "title is nil!")")
                        
                        self.collectionView?.reloadData()
                    //}
            
                },
                onError: { error in
                        print( "ERROR \(error)")
                }
            ).addDisposableTo(disposeBag)
        
        //self.collectionView?.setNeedsFocusUpdate()
        //self.collectionView?.updateFocusIfNeeded()
        
        
        // SETTINGS
        
        Settings.subscribe(setting: .SearchHMargins) { (newValue) -> Void in
            print("Set Horizontal Margin was changed to \(String(describing: newValue))")
            self.collectionView?.reloadData()
        }

    }
    
    
    // MARK: UICollectionViewDataSource
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDataItems.count
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchSlideCollectionViewCell.reuseIdentifier, for: indexPath) as! SearchSlideCollectionViewCell

        return cell
        
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    
    // Space between item on different row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }

    // Space between item on the same row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var result =  UIEdgeInsets( top: 30, left: 30, bottom: 30, right: 30 )
    
        if let hm = Settings.get(setting: .SearchHMargins) as? CGFloat {
            
            result.left = hm
            result.right = hm
        }
        
        return result
    }
    
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize

    
    // MARK: UICollectionViewDelegate

    //override public func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool
 
    override open func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        
        coordinator.addCoordinatedAnimations( {

            if let cell = context.nextFocusedView as? SearchSlideCollectionViewCell  {
                self.detailView.show( cell.representedDataItem )
            }
            else {
                 self.detailView.hide()
            }

            
        }) {
                // on completed
        }
        
    }
    
    override open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SearchSlideCollectionViewCell else {
            fatalError("Expected to display a `DataItemCollectionViewCell`.")
        }
        
        let item:Slideshow = filteredDataItems[indexPath.row]
        
        cell.representedDataItem = item
 
    }
    
    override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? SearchSlideCollectionViewCell else {
            fatalError("Expected to display a `DataItemCollectionViewCell`.")
        }
        
        let item:Slideshow = filteredDataItems[indexPath.row]
        
        rxDownload(presentation: item, showOnCell: cell)
        
    }
    
    // MARK: UISearchResultsUpdating
    
    open func updateSearchResults(for searchController: UISearchController) {
        
        searchResultsUpdatingSubject.onNext(searchController.searchBar.text ?? "")
    
    }
    
    // MARK: Segue
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let info = sender as? DocumentInfo {
            
            if let destinationViewController = segue.destination as? UIPDFCollectionViewController {
                
                destinationViewController.documentInfo = info

            }
        }
    }
    
}
