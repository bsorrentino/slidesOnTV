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
         .subscribe(  onNext: { [unowned self] value in
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


         let itemDeselected  = tableView.rx.itemDeselected
         .do( onNext: { (value) in
         print( "item deselected")
         })
         
         itemDeselected.subscribe(onNext: { (selectedIndex) in
         
         }).disposed(by: disposeBag)
         
         */

        
        let itemSelected    = tableView.rx.itemSelected
            .do( onNext: { (value) in
                print( "item selected")
            })
        
        let modelSelected = tableView.rx.modelSelected(FavoriteData.self)

        
        Observable.combineLatest( modelSelected,itemSelected )
            .subscribeOn(MainScheduler.instance)
            .subscribe { [unowned self] (value) in
                
                guard   let index       = value.element?.1,
                        let data        = value.element?.0 else { return }
                
                self.showEditMenu( data:data, selectedIndex:index )
                
            }.disposed(by: disposeBag)
        
        
        favoriteItems
        .asObservable()
        .bind(to: tableView.rx.items(cellIdentifier: "favoriteCell", cellType: UIFavoriteCell.self)) { (row, element, cell) in
        
                if let data = element.value as? [String:String], let title = data["title"] {
                
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.text = "\(title) @ row \(row)"
        
            }
        }.disposed(by: disposeBag)
        
        favoriteItems.value.append(contentsOf: favorites() )

        
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
    
    // MARK: ALERT ACTION
    
    fileprivate var alertDisposeBag:DisposeBag?
    fileprivate let downloadAction = PublishSubject<UIAlertAction>();
    fileprivate let deleteAction = PublishSubject<UIAlertAction>();
    
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

// MARK: ACTIONS

extension FavoritesViewController {

    fileprivate func downloadProgressView( from: UIFavoriteCell ) -> UIProgressView? {
        guard  let selectedView = from.selectedBackgroundView as? FavoritesCommandView,
            let progressView = selectedView.downloadProgressView else {
            return nil
        }
        return progressView
    }
    
    private func createAlertController( title:String? ) -> UIAlertController {
        
        let alertController = UIAlertController(title: "FAVORITES",
                                                message: title ?? "",
                                                preferredStyle: .actionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "CANCEL", style: .cancel ))
        alertController.addAction(UIAlertAction(title: "DOWNLOAD", style: .default) { [unowned self] (value) in
            self.downloadAction.onNext(value)
        })
        alertController.addAction(UIAlertAction(title: "DELETE", style: .destructive) { [unowned self] (value) in
            self.deleteAction.onNext(value)
        })
        
        return alertController
        
    }
    
    func showEditMenu( data:FavoriteData, selectedIndex:IndexPath ) {
        
        guard let cell = self.tableView?.cellForRow(at: selectedIndex) as? UIFavoriteCell  else { return }
        
        alertDisposeBag = DisposeBag()
        
        downloadAction.flatMap { (value) in
            
            return rxSlideshareCredentials()
                        .flatMap { (credentials) in
                            rxSlideshareGet(credentials:credentials, id: data.key)
                        }
                        .asObservable()
                        .flatMap { (data:Data) -> Observable<Slideshow> in
                            
                            let slidehareItemsParser = SlideshareItemsParser()
                            
                            return slidehareItemsParser.rx_parse(data)
                        }
                        .catchErrorJustReturn([DocumentField.ID:data.key])
            }
            .subscribe( onNext: { [unowned self] (slide:Slideshow) in

                do {
                    
                    try self.downloadPresentationFormURL( item:slide, relatedCell:cell )
                    
                }
                catch( let e  ) {
                    print( "error downloading presentation \(e)")
                }
            
            })
            .addDisposableTo(alertDisposeBag!)
        

        deleteAction.subscribe( onNext: { [unowned self] (value) in
            
                    favoriteRemove(key: data.key, synchronize: true)
                    self.favoriteItems.value.remove(at: selectedIndex.row)
                    //self.tableView.beginUpdates()
                    //self.tableView.deleteRows(at: [selectedIndex], with: .fade)
                    //self.tableView.endUpdates()

                })
            .addDisposableTo(alertDisposeBag!)


        var title:String?
        if let attrs = data.value as? [String:String] {
            title = attrs["title"]
        }
        
        let alertController = createAlertController( title: title )
        

        self.present(alertController, animated: true, completion: nil)
    }
   
    //
    // MARK: Download and Show Presentation
    //
    
    func downloadPresentationFormURL( item:Slideshow, relatedCell:UIFavoriteCell ) throws {
        guard   let documentId = item[DocumentField.ID],
            let documentTitle = item[DocumentField.Title] else { return }
        
        guard   let url = item[DocumentField.DownloadUrl]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
            let downloadURL = URL(string:url) else { return }
        
        let documentDirectoryURL =  try FileManager().url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let _ = TCBlobDownloadManager.sharedInstance.downloadFileAtURL(downloadURL,
                                                                       toDirectory: documentDirectoryURL,
                                                                       withName: "presentation.pdf",
                                                                       progression:
            { [unowned self] (progress, totalBytesWritten, totalBytesExpectedToWrite) in

                if let progressView = self.downloadProgressView(from: relatedCell) {
                    
                    print( "\(progress)")
                    progressView.progress = progress
                }
        })
        { [unowned self] (error, location) in
            
            
            if let error = error {
                
                debugPrint(error)
            }
            else {
                
                self.performSegue(withIdentifier: "showFavoritePresentation",
                                  sender: DocumentInfo( location:location!, id:documentId, title:documentTitle) )
            }
        }
        
        
        
    }
    
    
}

// MARK: FOCUS EXTENSION

extension FavoritesViewController {
    
    
    
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        
        print( "\(String(describing: type(of: self))).shouldUpdateFocus: \(describing(context.focusHeading))" )
        
        if context.focusHeading == .up || context.focusHeading == .down {
            print( "\(String(describing: tableView.indexPathForSelectedRow))")
            //guard let selectedIndex = tableView.indexPathForSelectedRow else { return true }
            
            //updateFocusSubject.onNext(selectedIndex)
            
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
