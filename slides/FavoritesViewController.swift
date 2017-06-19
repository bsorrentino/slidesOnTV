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
        
        selectedBackgroundView = UIProgressView()
    }
    
}


class FavoritesViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()
    
    
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
        
        let itemSelected = tableView.rx.itemSelected
        let valueSelected = tableView.rx.modelSelected(FavoriteData.self)
        
        Observable.combineLatest( itemSelected, valueSelected )
            .subscribe { [weak self] (value) in
 
                guard let element = value.element else {
                    return
                }
                if let cell = self?.tableView?.cellForRow(at: element.0) as? UIFavoriteCell {
                    
                    let data:FavoriteData = element.1
                    
                    do {
                        
                    try self?.downloadPresentationFormURL( element:data, relatedCell:cell )
                    
                    }
                    catch( let e  ) {
                        print( "error downloading presentation \(e)")
                    }
                }

                

            }.disposed(by: disposeBag)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var bindTo:Disposable?
    
    override func viewWillAppear(_ animated: Bool) {
        let favoriteItems = rxFavorites().toArray()
        
        bindTo = favoriteItems
            .bind(to: tableView.rx.items(cellIdentifier: "favoriteCell", cellType: UIFavoriteCell.self)) { (row, element, cell) in
                
                if let data = element.value as? [String:String], let title = data["title"] {
                    
                    cell.textLabel?.textAlignment = .center
                    cell.textLabel?.text = "\(title) @ row \(row)"
                    
                }
            }
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
    func downloadPresentationFormURL( element:FavoriteData, relatedCell:UIFavoriteCell ) throws {
        guard let data = element.value as? [String:String],
            let url = data["url"],
            let documentTitle = data["title"]
            else
        {
                return
        }
        
        guard let downloadURL = URL( string:url ) else {
            return
        }
        
        let documentDirectoryURL =  try FileManager().url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        
        let _ = TCBlobDownloadManager.sharedInstance.downloadFileAtURL(downloadURL,
                                                                       toDirectory: documentDirectoryURL,
                                                                       withName: "presentation.pdf",
                                                                       progression:
            { (progress, totalBytesWritten, totalBytesExpectedToWrite) in
                
                //let percentage = round( Float((totalBytesWritten * 100)/totalBytesExpectedToWrite) )
                //print( "\(progress) - \(totalBytesWritten) - \(totalBytesExpectedToWrite) %: \(percentage)" )
                //relatedCell.setProgress( percentage )
                
                //relatedCell.setProgress(progress)
                
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
                
                self.performSegue(withIdentifier: "showFavoritePresentation", sender: DocumentInfo( location:location!, url:downloadURL, title:documentTitle) )
            }
        }
        
        
        
    }
    
}
