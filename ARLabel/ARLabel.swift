//
//  ARLabel.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 24/04/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//


extension  UILabel {

    
    fileprivate func calculateSizeWithFont( _ font:UIFont,  text:NSString, constrainedToSize:CGSize ) -> CGSize {
        
        let frame = text.boundingRect(with: constrainedToSize,
                                              options: .usesLineFragmentOrigin, //| .UsesFontLeading,
            attributes:[NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue):font],
                                              context:nil)
    
        return frame.size;
    }
    
    func setFontThatFitsWithSize() -> CGSize
    {
        // This method is here to solve problems that the built-in UILabel adjustsFontSizeToFitWidth has. For
        // example fitting size also by height and centering by height(this is an accidental fix)...
        // The hardcoded values here are derived from experimentation and the purpose of them is to reduce the font
        // by a small amount, because otherwise the text would be, in some cases, drawn beyond label boundaries.
        
        guard let templateText = self.text else {
            return CGSize.zero;

        }
    
        var newFont = self.font
    
        let baseFont    = newFont?.pointSize
        var previousH   = newFont?.pointSize
        var fSize        = CGSize.zero
        var step:CGFloat = 0.2
        let rect         = self.frame
    
        repeat  {
            newFont  = UIFont.systemFont(ofSize: baseFont!+step)
        
            fSize   = self.calculateSizeWithFont( newFont!, text:templateText as NSString, constrainedToSize:rect.size )
        
            if(fSize.height + (newFont?.lineHeight)! > rect.size.height ) {
        
                newFont  =   UIFont.systemFont(ofSize: previousH!)
                fSize   =   CGSize(width: fSize.width, height: previousH!)
                break
            }
            else {
                step += 1
                previousH = baseFont! + step
            }
        
        } while (true);
    
    self.font = newFont;
        
    return fSize;
    }
    
    
}
