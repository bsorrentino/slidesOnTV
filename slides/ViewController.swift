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
        
        let testLabel = ARLabel(frame:CGRectMake(110, 100, 100, 50))
        testLabel.text = "TEST0\nTEST1"
        testLabel.enlargedSize = CGSizeMake(200, 100)
        testLabel.numberOfLines = 2
        
        self.view.addSubview(testLabel)

        UIView.animateWithDuration(3.0,
                                   delay: 1.0,
                                   options: .CurveEaseInOut,
                                   animations: {

                                    testLabel.frame = CGRectMake(60, 200, 200*2, 100*2);
            
                                }) { (complete:Bool) in
        }
        
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

