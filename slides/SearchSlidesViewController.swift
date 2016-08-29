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


class Scheduler {
    
    // implicit lazy
    static var backgroundWork: ImmediateSchedulerType = {
        
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        
        return OperationQueueScheduler(operationQueue: operationQueue)
        
    }()
}

class SearchSlideCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties

    static let reuseIdentifier = "SearchSlideCell"

    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var thumbnail: UIImageView?
    
    private lazy var loadingView:UAProgressView? = self.initLoadingView()
    
    private var _representedDataItem: Slideshow?
    var representedDataItem: Slideshow?  {
        
        set {
            
            self._representedDataItem = newValue
            
            guard let item = newValue else {
                return;
            }
            
            if let title = item["title"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                
                self.label.text = title
            }
            
            if let thumbnail = item["thumbnailxlargeurl"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                
                let s = "http:\(thumbnail)"
                
                if let url = NSURL(string: s ) {
                    
                    self.loadImageUrl(url, backgroundWorkScheduler: Scheduler.backgroundWork)
                }
            }

        }
        get {
            return self._representedDataItem
        }
    }
    
    var disposeBag: DisposeBag?
    
    func loadImageUrl( imageUrl:NSURL, backgroundWorkScheduler:ImmediateSchedulerType )  {
            let disposeBag = DisposeBag()
            
            NSURLSession.sharedSession().rx_data(NSURLRequest(URL: imageUrl))
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
            
            let size = CGSizeMake(250, 250)
            let center = CGPointMake( thumbnail.center.x - size.width/2, thumbnail.center.y - size.height/2 )
            
            let frame = CGRectMake(center.x, center.y, size.width,size.height)
            
            let circleView =  UAProgressView(frame: frame)
            circleView.borderWidth = 10
            circleView.lineWidth = 5
            circleView.setFillAlpha(0.5)
            
            let label = UILabel(frame:CGRectMake(0, 0, 120.0, 40.0))
            label.textAlignment = .Center
            label.userInteractionEnabled = false; // Allows tap to pass through to the progress view.
            label.font = UIFont.boldSystemFontOfSize(30.0)
            label.textColor = UIColor.whiteColor() //circleView.tintColor
            
            circleView.centralView = label;
            
            
            circleView.progressChangedBlock = { (progressView:UAProgressView!, progress:CGFloat) in
                
                if let label = progressView.centralView as? UILabel {
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
    
    func setProgress( progress:Float) {
        
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
    
    var font:UIFont?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // These properties are also exposed in Interface Builder.
        thumbnail?.adjustsImageWhenAncestorFocused = true
        thumbnail?.clipsToBounds = false
        label?.clipsToBounds = false
        label.adjustsFontSizeToFitWidth = true
        
        font = label.font

    }

    // MARK: UICollectionReusableView
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil

    }
    
    // MARK: UIFocusEnvironment
    
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator )
    {
        /*
        label.font = font
        
        coordinator.addCoordinatedAnimations({
            if self.focused {
                self.label.layer.zPosition = (self.thumbnail?.layer.zPosition)! + 1
                
                self.label.backgroundColor = UIColor.whiteColor()

                self.label.transform = CGAffineTransformConcat(
                                            CGAffineTransformMakeScale(1.1, 2.7),
                                            CGAffineTransformMakeTranslation(0, -50))

            }
            else {
                
                self.label.transform = CGAffineTransformConcat(
                    CGAffineTransformMakeTranslation(0, 0),
                    CGAffineTransformMakeScale(1.0, 1.0))
                
                self.label.backgroundColor = UIColor.clearColor()

                self.label.layer.zPosition = (self.thumbnail?.layer.zPosition)! - 1
           }
        }) {
            
            if self.focused {
                self.label.setFontThatFitsWithSize()
            }
        }
        */
    }
}


class DetailView : UIView {
    
    var originalHeight:CGFloat = 0.0
    
    static func loadFromNib() -> DetailView {
        
        let nibViews = NSBundle.mainBundle().loadNibNamed("DetailView", owner: nil, options: nil)
        
        for v in nibViews {
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
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        if let superview = appDelegate.window  {
            
            
            self.snp_updateConstraints { (make) in
                
                let offsetFromBottom = self.frame.size.height + 60 // dy - see AppDelegate
                make.width.equalTo(superview)
                make.bottom.equalTo(superview.snp_bottom).offset(-offsetFromBottom)
                //make.leading.equalTo(superview)
            }
        }
        
        super.updateConstraints()
    }
    
    func addToWindow() -> DetailView {
 
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let superview = appDelegate.window  {
        
            self.addTo(superview)
        }
        
        return self
    }
    
    func addTo(superview: UIView) -> DetailView {
        
        superview.addSubview( self )
        
        return self
    }
    
    func show(item:Slideshow?) {
        
        self.hidden = false
        
        var frame = self.frame
        
        frame.size.height = originalHeight
        
        self.frame = frame
    }

    func hide() {
        
        self.hidden = true
        
        var frame = self.frame
        
        frame.size.height = 0
        
        self.frame = frame
    }
    
}




public class SearchSlidesViewController: UICollectionViewController, UISearchResultsUpdating {
    // MARK: Properties
    
    public static let storyboardIdentifier = "SearchSlidesViewController"
    
    private var filteredDataItems:[Slideshow] = []
    
    private lazy var detailView:DetailView = DetailView.loadFromNib()
    
    let disposeBag = DisposeBag()
    
    let searchResultsUpdatingSubject = PublishSubject<String>()

    
    func downloadPresentationFormURL( downloadURL:NSURL, relatedCell:SearchSlideCollectionViewCell ) throws {
        
        let documentDirectoryURL =  try NSFileManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
       
        relatedCell.showProgress()
        
        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(downloadURL,
                                                               toDirectory: documentDirectoryURL,
                                                               withName: "presentation.pdf",
                                                               progression:
            { (progress, totalBytesWritten, totalBytesExpectedToWrite) in
                
                //let percentage = round( Float((totalBytesWritten * 100)/totalBytesExpectedToWrite) )
                //print( "\(progress) - \(totalBytesWritten) - \(totalBytesExpectedToWrite) %: \(percentage)" )
                //relatedCell.setProgress( percentage )
                
                relatedCell.setProgress(progress)
            })
            { (error, location) in

                
                if let error = error {
                 
                    debugPrint(error)
                }
                else {
                    
                    //print( "Download completed at location \(location)")
                    
                    self.performSegueWithIdentifier("showPresentation", sender: location)
                }
                relatedCell.resetProgress()
            }
        

        
    }
    
    
    // MARK: UICollectionViewController Lifecycle

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let bundlePath = NSBundle.mainBundle().pathForResource("slideshare", ofType: "plist") else {
            return
        }
        
        guard let credentials = NSDictionary(contentsOfFile: bundlePath ) else {
            return
        }
        
        // Initilaize DetailView
        
        detailView.addToWindow().hide()
        
        
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
        .flatMap( {  (filterString) -> Observable<NSData> in
        
            return slideshareSearch( apiKey: credentials["apiKey"]! as! String, sharedSecret: credentials["sharedSecret"] as! String, what: filterString )
        })
        .debug("parse")
        .doOnNext({ (_) in self.filteredDataItems.removeAll() })
        .flatMap({ (data:NSData) -> Observable<Slideshow> in

            let slidehareItemsParser = SlideshareItemsParser()
            
            return slidehareItemsParser.rx_parse(data)
        })
        .debug( "subscribe")
        .filter({ (slide:Slideshow) -> Bool in
        
            if let format = slide["format"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                return format.lowercaseString=="pdf"
            }
            return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe({ e in
            
            if let slide = e.element {
                
                self.filteredDataItems.append(slide)
                
                let title = slide["title"]
                
                print( "\(title)")
                
                self.collectionView?.reloadData()
            }
            
        }).addDisposableTo(disposeBag)
        
        //self.collectionView?.setNeedsFocusUpdate()
        //self.collectionView?.updateFocusIfNeeded()
        
        
        // SETTINGS
        
        Settings.subscribe(.SearchHMargins) { (newValue) -> Void in
            print("Set Horizontal Margin was changed to \(newValue)")
            self.collectionView?.reloadData()
        }

    }
    
    
    // MARK: UICollectionViewDataSource
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDataItems.count
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SearchSlideCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! SearchSlideCollectionViewCell

        return cell
        
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    
    // Space between item on different row
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }

    // Space between item on the same row
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var result =  UIEdgeInsets( top: 30, left: 30, bottom: 30, right: 30 )
    
        if let hm = Settings.get(.SearchHMargins) as? CGFloat {
            
            result.left = hm
            result.right = hm
        }
        
        return result
    }
    
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize

    
    // MARK: UICollectionViewDelegate

    //override public func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool
 
    override public func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
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
    
    override public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? SearchSlideCollectionViewCell else {
            fatalError("Expected to display a `DataItemCollectionViewCell`.")
        }
        
        let item:Slideshow = filteredDataItems[indexPath.row]
        
        cell.representedDataItem = item
 
    }
    
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SearchSlideCollectionViewCell else {
            fatalError("Expected to display a `DataItemCollectionViewCell`.")
        }
        
        let item:Slideshow = filteredDataItems[indexPath.row]
       
        if let url = item["downloadurl"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())  {
            
            print( "\(url)")
            
            if let downloadURL = NSURL(string:url) {
                do {
                    try downloadPresentationFormURL( downloadURL, relatedCell:cell)
                }
                catch {
                    print( "error downloading url")
                }
            }
        }
        
    }
    
    // MARK: UISearchResultsUpdating
    
    public func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        searchResultsUpdatingSubject.onNext(searchController.searchBar.text ?? "")
    
    }
    
    // MARK: Segue
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let location = sender as? NSURL {
            
            if let destinationViewController = segue.destinationViewController as? UIPDFCollectionViewController {
                
                destinationViewController.documentLocation = location

            }
        }
    }
    
}
