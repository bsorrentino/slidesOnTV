//
//  ARLabel.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 24/04/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//


extension  UILabel {

    
    private func calculateSizeWithFont( font:UIFont,  text:NSString, constrainedToSize:CGSize ) -> CGSize {
        let attributesDictionary:Dictionary<String,AnyObject> = [NSFontAttributeName:font]
        
        let frame = text.boundingRectWithSize(constrainedToSize,
                                              options: .UsesLineFragmentOrigin, //| .UsesFontLeading,
                                              attributes:attributesDictionary,
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
            return CGSizeZero;

        }
    
        var newFont = self.font
    
        let baseFont    = newFont.pointSize
        var previousH   = newFont.pointSize
        var fSize        = CGSizeZero
        var step:CGFloat   = 0.1
        let rect         = self.bounds
    
        repeat  {
            newFont  = UIFont.systemFontOfSize(baseFont+step)
        
            fSize   = self.calculateSizeWithFont( newFont, text:templateText, constrainedToSize:rect.size )
        
            if(fSize.height + newFont.lineHeight > rect.size.height ) {
        
                newFont  =   UIFont.systemFontOfSize(previousH)
                fSize   =   CGSizeMake(fSize.width, previousH)
                break
            }
            else {
                previousH = baseFont + step++
            }
        
        } while (true);
    
    self.font = newFont;
        
    return fSize;
    }
    
    
}