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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        /*
        tableView.rx
            .modelSelected(String.self)
            .subscribe(onNext:  { value in
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemAccessoryButtonTapped
            .subscribe(onNext: { indexPath in
            })
            .disposed(by: disposeBag)
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var bindTo:Disposable?
    
    override func viewWillAppear(_ animated: Bool) {
        let favoriteItems = rxFavorites().toArray()
        
        bindTo = favoriteItems
            .bind(to: tableView.rx.items(cellIdentifier: "favoriteCell", cellType: UITableViewCell.self)) { (row, element, cell) in
                
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

}
