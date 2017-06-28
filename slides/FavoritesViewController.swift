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



class FavoritesViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    let updateFocusSubject = PublishSubject<IndexPath>()
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

        let itemDeselected  = tableView.rx.itemDeselected
            .do( onNext: { (value) in
                print( "item deselected")
            })
        
        /*
        updateFocusSubject.subscribe(onNext: { (selectedIndex) in
            
            
            if let cell = self.tableView?.cellForRow(at: selectedIndex) as? UIFavoriteCell {
                cell.setEditing( false, animated: false)
            }
            self.tableView.deselectRow(at: selectedIndex, animated: true)

        }).disposed(by: disposeBag)
        */
        itemDeselected.subscribe(onNext: { (selectedIndex) in
            
            
            if let cell = self.tableView?.cellForRow(at: selectedIndex) as? UIFavoriteCell {
                cell.setEditing( false, animated: true)
            }
            //self.tableView.deselectRow(at: selectedIndex, animated: true)
            
        }).disposed(by: disposeBag)
        
        let itemSelected    = tableView.rx.itemSelected
            .do( onNext: { (value) in
                print( "item selected")
            })
        
        let modelSelected = tableView.rx.modelSelected(FavoriteData.self)

        
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
        
        Observable.combineLatest( itemSelected, modelSelected )
            .subscribe { [weak self] (value) in
                
            
                self?.showEditMenu()
                
                
                    /*
                    let data:Slideshow = element.1
                    
                    do {
                        
                    try self?.downloadPresentationFormURL( item:data, relatedCell:cell )
                    
                    }
                    catch( let e  ) {
                        print( "error downloading presentation \(e)")
                    }
                    */
            }.disposed(by: disposeBag)

    }
    
    private var bindTo:Disposable?
    
    private func rxLoadData() -> Disposable {
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
    
    func showEditMenu() {
        let allertController = UIAlertController(title: "TITLE", message: "MESSAGE", preferredStyle: .actionSheet)
        
        // Cancel action (is invisible, but enables escape)
        //allertController.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        allertController.addAction(UIAlertAction(title: "DOWNLOAD", style: .default, handler: nil))
        allertController.addAction(UIAlertAction(title: "DELETE", style: .destructive, handler: nil))
        
        self.present(allertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindTo = rxLoadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        bindTo?.dispose()
    }
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        /*
        if indexPath  == currentSelection { return 160 }
        */
        return 80
    }
    
    // MARK: SEGUE
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let info = sender as? DocumentInfo {
            
            if let destinationViewController = segue.destination as? UIPDFCollectionViewController {
                
                destinationViewController.documentInfo = info
                
            }
        }
    }

    // MARK: MEM MANAGEMENT

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK EDIT EXTENSION

/*
extension FavoritesViewController {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        return .none
    }
    

}
*/

// MARK: FOCUS EXTENSION

extension FavoritesViewController {
    
    
    
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        
        print( "\(String(describing: type(of: self))).shouldUpdateFocus: \(describing(context.focusHeading))" )
        
        if context.focusHeading == .up || context.focusHeading == .down {
            print( "\(String(describing: tableView.indexPathForSelectedRow))")
            guard let selectedIndex = tableView.indexPathForSelectedRow else { return true }
            
            updateFocusSubject.onNext(selectedIndex)
            
            //
            // CHECK IF THE FOCUS COMING FROM "FavoritesCommandView" 
            //
            /*
            if  let _ = context.previouslyFocusedView as? UIButton,
                let selectedIndex = self.tableView.indexPathForSelectedRow
            {
                print( "selectedIndex \(selectedIndex)")
                
                if let cell = tableView?.cellForRow(at: currentSelection!) as? UIFavoriteCell {
                    cell.setEditing( false, animated: true )
                }
                self.currentSelection = nil

                self.tableView.deselectRow(at: selectedIndex, animated: true)
                
            }
            */
        }
        return true
    }
    
    
}
