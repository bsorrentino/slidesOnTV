//
//  ViewController.swift
//  slides
//
//  Created by softphone on 31/03/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var pushMe: UIButton!
    @IBOutlet weak var testLabel: UILabel!
    
    fileprivate var expand = true
    
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        
        print( "preferredFocusEnvironments")
        return [pushMe]

    }
    
    @IBAction func animateLabel(_ sender: AnyObject) {
        
        let frame = testLabel.frame;
        
        print( frame )

        UIView.animate(withDuration: 3.0,
                                   delay: 1.0,
                                   options: [.curveLinear, .allowAnimatedContent],
                                   animations: {
                                    
                                    if( self.expand ) {

                                        self.testLabel.transform = CGAffineTransform(scaleX: 2.3, y: 1.5)
                                        
                                    }
                                    else {
                                        
                                        self.testLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                    }
        }) { (complete:Bool) in
            
            print( self.testLabel.frame )
            
            
            self.expand = !self.expand
            
            let _ = self.testLabel.setFontThatFitsWithSize()
        }
        
    }
    
    fileprivate func addAndAnimateLabel() {
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
    
    // MARK: Segue
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            
        if let destinationViewController = segue.destination as? UIPDFCollectionViewController {
            
            if let path = Bundle.main.url(forResource: "rx1", withExtension:"pdf") {

                destinationViewController.documentInfo = DocumentInfo( location:path, id:"test-document", title:"RX" )
             }
        }
    }

}

