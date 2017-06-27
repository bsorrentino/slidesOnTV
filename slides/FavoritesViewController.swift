//
//  FavoritesViewController.swift
//  slides
//
//  Created by softphone on 13/06/2017.
//  Copyright © 2017 soulsoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class UIFavoriteCell : UITableViewCell {

    
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    private var _preferredFocusEnvironments:[UIFocusEnvironment]?
    
    override var preferredFocusEnvironments : [UIFocusEnvironment] {
        return _preferredFocusEnvironments ?? super.preferredFocusEnvironments
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        print( "setSelected \(selected)")
        super.setSelected(selected, animated: animated)
        
        if selected {
            _preferredFocusEnvironments = [self.selectedBackgroundView!]
        }
        else {
            self.selectedBackgroundView?.removeFromSuperview()
            _preferredFocusEnvironments = nil
        }
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        
        print( "\(String(describing: type(of: self))).shouldUpdateFocus: \(describing(context.focusHeading))" )

        if context.focusHeading == .left || context.focusHeading == .right {
            if context.nextFocusedView == self {
                // GAIN FOCUS
                
            } else if context.previouslyFocusedView == self {
                // LOST FOCUS
            }
            self.selectedBackgroundView?.setNeedsFocusUpdate()
            
        }
        return true
    }
    
    /*
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if context.nextFocusedView == self {
            // GAIN FOCUS
            
            print( "GAIN FOCUS \(self.textLabel?.text ?? "undef")")

        } else if context.previouslyFocusedView == self {
            // LOST FOCUS

            print( "LOST FOCUS \(self.textLabel?.text ?? "undef")")
        }
    }
    */
}


class FavoritesViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()
    
    fileprivate var _currentSelection:IndexPath?
    fileprivate var currentSelection:IndexPath? {
        get {
            return _currentSelection
        }
        set {
            _currentSelection = newValue
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    let favoriteItems: Variable<[FavoriteData]> = Variable([])

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setEditing(true, animated: false)
        /*
         tableView.rx.itemSelected
         .subscribe(  onNext: { [weak self] value in
         })
         .disposed(by: disposeBag)

        
        tableView.rx
            .modelSelected(FavoriteData.self)
            .subscribe(onNext:  { value in
            })
            .disposed(by: disposeBag)
        
         tableView.rx
         .itemAccessoryButtonTapped
         .subscribe(onNext: { indexPath in
         })
         .disposed(by: disposeBag)
         */
        
        
        let itemSelected = tableView.rx.itemSelected
        
        let modelSelected =
            tableView.rx.modelSelected(FavoriteData.self)
        
        let valueSelected =  modelSelected
            .flatMap { (element) -> Observable<Slideshow> in
                
                let getSlideData =  rxSlideshareCredentials()
                    .flatMap { (credentials) in
                        rxSlideshareGet(credentials:credentials, id: element.key)
                    }
                
                return getSlideData.asObservable()
                    .flatMap { (data:Data) -> Observable<Slideshow> in
                        
                        let slidehareItemsParser = SlideshareItemsParser()
                        
                        return slidehareItemsParser.rx_parse(data)
                }

            }
        
        var onRemove:Disposable?

        Observable.combineLatest( itemSelected, modelSelected )
            .subscribe { [weak self] (value) in
                
                onRemove?.dispose()
                
                guard let _self = self else {
                    return
                }
                guard let element = value.element else {
                    return
                }
                
                
                if let cell = _self.tableView?.cellForRow(at: element.0) as? UIFavoriteCell {
                    

                    _self.currentSelection = element.0
                    
                    if let commandView = cell.selectedBackgroundView as? FavoritesCommandView {
                        
                        onRemove = commandView
                            .removeButton
                            .subscribe( onNext: { _ in
                                favoriteRemove(key: element.1.key, synchronize: true )
                                _self.tableView.beginUpdates()
                                _self.tableView.deleteRows(at: [element.0], with: .none)
                                _self.favoriteItems.value.remove(at: element.0.row)
                                _self.tableView.endUpdates()
                                
                            })
                                
                        
                    }
                
                    /*
                    let data:Slideshow = element.1
                    
                    do {
                        
                    try self?.downloadPresentationFormURL( item:data, relatedCell:cell )
                    
                    }
                    catch( let e  ) {
                        print( "error downloading presentation \(e)")
                    }
                    */
                }

            }.disposed(by: disposeBag)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var bindTo:Disposable?
    
    private func rxReloadData() -> Disposable {
        favoriteItems.value.append(contentsOf: favorites() )
        
        return favoriteItems
        .asObservable()
        .bind(to: tableView.rx.items(cellIdentifier: "favoriteCell", cellType: UIFavoriteCell.self)) { (row, element, cell) in
        
                if let data = element.value as? [String:String], let title = data["title"] {
                
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.text = "\(title) @ row \(row)"
        
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bindTo = rxReloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        bindTo?.dispose()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //
    // MARK: Download and Show Presentation
    //
    func downloadPresentationFormURL( item:Slideshow, relatedCell:UIFavoriteCell ) throws {
        guard let documentId = item[DocumentField.ID],
            let documentTitle = item[DocumentField.Title]
            else
        {
                return
        }
        
        guard let url = item[DocumentField.DownloadUrl]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), let downloadURL = URL(string:url) else {
            return
        }

        let documentDirectoryURL =  try FileManager().url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        
        let _ = TCBlobDownloadManager.sharedInstance.downloadFileAtURL(downloadURL,
                                                                       toDirectory: documentDirectoryURL,
                                                                       withName: "presentation.pdf",
                                                                       progression:
            { (progress, totalBytesWritten, totalBytesExpectedToWrite) in
                
                if let progressView = relatedCell.selectedBackgroundView as? UIProgressView {
                    
                    print( "\(progress)")
                    progressView.progress = progress
                }
        })
        { (error, location) in
            
            
            if let error = error {
                
                debugPrint(error)
            }
            else {
                
                self.performSegue(withIdentifier: "showFavoritePresentation", sender: DocumentInfo( location:location!, id:documentId, title:documentTitle) )
            }
        }
        
        
        
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

extension FavoritesViewController {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 80
    }
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        
        print( "\(String(describing: type(of: self))).shouldUpdateFocus: \(describing(context.focusHeading))" )
        
        if context.focusHeading == .up || context.focusHeading == .down {
            
            //
            // CHECK IF THE FOCUS COMING FROM "FavoritesCommandView" 
            //
            if  let _ = context.previouslyFocusedView as? UIButton,
                let selectedIndex = self.tableView.indexPathForSelectedRow
            {
                print( "selectedIndex \(selectedIndex)")
                self.tableView.deselectRow(at: selectedIndex, animated: true)
            }
        }
        return true
    }

    
}
