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
    @IBOutlet weak var testLabel: UILabel!
    
    private var expand = true
    
    @IBAction func animateLabel(sender: AnyObject) {
        
        let frame = testLabel.frame;
        
        print( frame )

        UIView.animateWithDuration(3.0,
                                   delay: 1.0,
                                   options: [.CurveLinear, .AllowAnimatedContent],
                                   animations: {
                                    
                                    if( self.expand ) {

                                        self.testLabel.transform = CGAffineTransformMakeScale(2.3, 1.5)
                                        
                                    }
                                    else {
                                        
                                        self.testLabel.transform = CGAffineTransformMakeScale(1.0, 1.0)
                                    }
        }) { (complete:Bool) in
            
            print( self.testLabel.frame )
            
            
            self.expand = !self.expand
            
            self.testLabel.setFontThatFitsWithSize()
        }
        
    }
    
    private func addAndAnimateLabel() {
        
        /*
        let test1Label = ARLabel(frame:CGRectMake(110, 100, 100, 50))
        test1Label.text = "TEST0\nTEST1"
        test1Label.enlargedSize = CGSizeMake(200, 100)
        test1Label.numberOfLines = 2
        
        self.view.addSubview(testLabel)
        
        UIView.animateWithDuration(3.0,
                                   delay: 1.0,
                                   options: .CurveEaseInOut,
                                   animations: {
                                    
                                    test1Label.frame = CGRectMake(60, 200, 200*2, 100*2);
                                    
        }) { (complete:Bool) in
        }
        */
    }
    
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

