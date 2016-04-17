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

class SearchSlideCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties

    static let reuseIdentifier = "SearchSlideCell"
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var thumbnail: UIImageView?
    
    private lazy var loadingView:UAProgressView? = self.initLoadingView()
    
    var representedDataItem: Slideshow?
    
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
            circleView.borderWidth = 15
            circleView.lineWidth = 5
            circleView.setFillAlpha(0.5)
            
            let label = UILabel(frame:CGRectMake(0, 0, 60.0, 20.0))
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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // These properties are also exposed in Interface Builder.
        //imageView?.adjustsImageWhenAncestorFocused = true
        //imageView?.clipsToBounds = false
        
    }

    // MARK: UICollectionReusableView
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
        disposeBag = nil

    }
    
    // MARK: UIFocusEnvironment   
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            if self.focused {
                self.transform = CGAffineTransformMakeScale(1.01, 1.01)
                self.backgroundColor = UIColor.whiteColor()
                //self.label.textColor = .blackColor()
            }
            else {
                self.transform = CGAffineTransformMakeScale(1, 1)
                self.backgroundColor = UIColor.clearColor()
                //self.label.textColor = .whiteColor()
            }
        }, completion: nil)    }
}


public class SearchSlidesViewController: UICollectionViewController, UISearchResultsUpdating {
    // MARK: Properties
    
    public static let storyboardIdentifier = "SearchSlidesViewController"
    
    private var backgroundWorkScheduler: ImmediateSchedulerType?
    
    private var filteredDataItems:[Slideshow] = []
    
    let disposeBag = DisposeBag()
    
    
    let searchResultsUpdatingSubject = PublishSubject<String>()

    
    func downloadPresentationFormURL( downloadURL:NSURL, relatedCell:SearchSlideCollectionViewCell ) throws {
        
        let documentDirectoryURL =  try NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
       
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
                    
                    print( "Download completed at location \(location)")
                    
                    self.performSegueWithIdentifier("showPresentation", sender: location)
                }
                relatedCell.resetProgress()
            }
        

        
    }
    
    // MARK: UICollectionViewController Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        
        self.backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
      
    
        guard let bundlePath = NSBundle.mainBundle().pathForResource("slideshare", ofType: "plist") else {
            return
        }
        
        guard let credentials = NSDictionary(contentsOfFile: bundlePath ) else {
            return
        }
        
        
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
        .flatMap({ (data:NSData) -> Observable<Slideshow> in

            self.filteredDataItems.removeAll()
            
            let slidehareItemsParser = SlideshareItemsParser()
            
            return slidehareItemsParser.rx_parse(data)
        })
        .observeOn(MainScheduler.instance)
        .debug( "subscribe")
        .subscribe({ e in
            

            if let slide = e.element {
                
                self.filteredDataItems.append(slide)
                
                let title = slide["title"]
                
                print( "\(title)")
                
                self.collectionView?.reloadData()
            }
            
        }).addDisposableTo(disposeBag)
        
        self.collectionView?.setNeedsFocusUpdate()
        self.collectionView?.updateFocusIfNeeded()

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
    
    // MARK: UICollectionViewDelegate
    
    override public func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    
    override public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? SearchSlideCollectionViewCell else { fatalError("Expected to display a `DataItemCollectionViewCell`.") }
        
        let item:Slideshow = filteredDataItems[indexPath.row]
        
        //item.forEach { (k, v) in print( "\(k)=\(v)") }
        
        if let title = item["title"] {
        
            cell.label.text = title
        
        }
        if let thumbnail = item["thumbnailxlargeurl"] {
            
            let s = "http:\(thumbnail)".stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            print( "[\(s)]" )
            if let url = NSURL(string: s ) {

                cell.loadImageUrl(url, backgroundWorkScheduler: self.backgroundWorkScheduler!)
            }
        }
        
        // Configure the cell.
        //cellComposer.composeCell(cell, withDataItem: item)

    }
    
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //dismissViewControllerAnimated(true, completion: nil)

        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SearchSlideCollectionViewCell else { fatalError("Expected to display a `DataItemCollectionViewCell`.") }
        
        let item:Slideshow = filteredDataItems[indexPath.row]
       
        if let url = item["downloadurl"]  {
            
            
            let urlDecode = url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) //.stringByRemovingPercentEncoding!
            
            print( "\(url) \(urlDecode)")
            
            if let downloadURL = NSURL(string:urlDecode) {
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
