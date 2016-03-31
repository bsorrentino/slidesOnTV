//
//  ViewController.swift
//  slides
//
//  Created by softphone on 31/03/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pushMe: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override weak var preferredFocusedView: UIView? {
        print( "preferredFocusedView")
        return pushMe
    }
}

