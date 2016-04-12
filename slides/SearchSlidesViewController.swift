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
    
    // MARK: Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // These properties are also exposed in Interface Builder.
        imageView?.adjustsImageWhenAncestorFocused = true
        imageView?.clipsToBounds = false
        
        //label.alpha = 0.0
    }
    
    // MARK: UICollectionReusableView
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset the label's alpha value so it's initially hidden.
        //label.alpha = 0.0
    }
    
    // MARK: UIFocusEnvironment
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        /*
         Update the label's alpha value using the `UIFocusAnimationCoordinator`.
         This will ensure all animations run alongside each other when the focus
         changes.
         */
        
        /*
        coordinator.addCoordinatedAnimations({
            if self.focused {
                self.label.alpha = 1.0
            }
            else {
                self.label.alpha = 0.0
            }
            }, completion: nil)
        */
    }
}


public class SearchSlidesViewController: UICollectionViewController, UISearchResultsUpdating {
    // MARK: Properties
    
    public static let storyboardIdentifier = "SearchSlidesViewController"
    
    //private let cellComposer = DataItemCellComposer()
    
    private var filteredDataItems:[Slideshow] = []
    
    let disposeBag = DisposeBag()
    
    
    let searchResultsUpdatingSubject = PublishSubject<String>()

  
    // MARK: UICollectionViewController Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
    
    
        searchResultsUpdatingSubject
        .filter( { (filter:String) -> Bool in
            let length = Int(filter.characters.count)
            
            print( "count \(length)")
            
            return length > 2
        })
        .debounce(3.5, scheduler: MainScheduler.instance)
        .debug("slideshareSearch")
        .flatMap( {  (filterString) -> Observable<NSData> in
        
            return slideshareSearch( apiKey: "N2ouIG0m", sharedSecret: "kWG85pR1", what: filterString )
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
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*
        guard let items = filteredDataItems else {
            return 0;
        }
        */
        return filteredDataItems.count
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SearchSlideCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! SearchSlideCollectionViewCell

            let item = filteredDataItems[indexPath.row]
            
            if let title = item["title"] {
                
                print( "\(title)" )
                
                cell.label.text = title
                
            }
            
            return cell
        
    }
    
    // MARK: UICollectionViewDelegate
    
    override public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? SearchSlideCollectionViewCell else { fatalError("Expected to display a `DataItemCollectionViewCell`.") }
        let item = filteredDataItems[indexPath.row]
        
        if let title = item["title"] {
        
            print( "\(title)" )
        
            //cell.label.text = title
        
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
