//
//  SlideSearchViewController.swift
//  slides
//
//  Created by softphone on 11/04/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//
import RxSwift
import RxCocoa

class SearchSlideCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties

    static let reuseIdentifier = "SearchSlideCell"
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var imageView: UIImageView?
    
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
                }).subscribe(
                    onNext: { (image) in
                    self.imageView?.image = image
                    },
                    onError: { (e) in
                        print( "ERROR: \(e)")
                    }
                )                //.trackActivity(self.loadingImage)
                .addDisposableTo(disposeBag)
            
                self.disposeBag = disposeBag
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UISearchResultsUpdating
    
    public func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        
        searchResultsUpdatingSubject.onNext(searchController.searchBar.text ?? "")
        
        
    }
}
