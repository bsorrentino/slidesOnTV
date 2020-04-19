//
//  DetailView.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 15/04/2020.
//  Copyright © 2020 soulsoftware. All rights reserved.
//

import UIKit

class DetailView : UIView {
    
    var originalHeight:CGFloat = 0.0
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var updatedLabel: UILabel!
    static func loadFromNib() -> DetailView {
        
        let nibViews = Bundle.main.loadNibNamed("DetailView", owner: nil, options: nil)
        
        for v in nibViews! {
            if let tog = v as? DetailView {
                return tog
            }
        }
        return DetailView()

    }
    override func awakeFromNib() {
        self.originalHeight = self.frame.size.height
    }
 
    override func updateConstraints() {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        if let superview = appDelegate.window  {
            
            
            self.snp.updateConstraints { (make) in
                
                make.height.equalTo(self.frame.size.height)
                make.width.equalTo(superview)
                make.bottom.equalTo(superview.snp.bottom)//.offset(-offsetFromBottom)
            }
        }
        
        super.updateConstraints()
    }
    
    func addToWindow() -> DetailView {
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let superview = appDelegate.window  {
        
            let _ = self.addTo(superview)
        }
        
        return self
    }
    
    func addTo(_ superview: UIView) -> DetailView {
        
        superview.addSubview( self )
        
        return self
    }
    
    func show(_ item:Slideshow? ) {
        self.alpha = 1.0
        self.layer.zPosition = 1
        //self.hidden = false
        
        var frame = self.frame
        
        frame.size.height = originalHeight
        
        self.frame = frame
        
        if let item = item {
            
            if let title = item[DocumentField.Title]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                
                self.titleLabel.text = title
            }
            
            if let updated = item[DocumentField.Updated] {
                self.updatedLabel.text = updated
            }
        }
        
        
        setNeedsUpdateConstraints()
    }

    func hide() {
        
        self.layer.zPosition = 0
        self.alpha = 0.0
        //self.hidden = true
        
        var frame = self.frame
        
        frame.size.height = 0
        
        self.frame = frame
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */


}

