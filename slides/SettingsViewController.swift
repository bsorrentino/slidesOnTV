//
//  SettingsViewController.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 14/04/2020.
//  Copyright © 2020 soulsoftware. All rights reserved.
//

import UIKit

protocol SettingsDelegate : class {
    
    func toggleFullscreen(_ sender: SettingButton)
    func addToFavorite(_ sender: SettingButton)
}

class SettingsViewController: UIViewController, NameDescribable {

    weak var delegate: SettingsDelegate?
    
    
    @IBAction func toggleFullscreen(_ sender: SettingButton) {
        if let delegate = self.delegate {
            delegate.toggleFullscreen(sender)
        }
     }

    @IBAction func addToFavorite(_ sender: SettingButton) {
        if let delegate = self.delegate {
            delegate.addToFavorite(sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
