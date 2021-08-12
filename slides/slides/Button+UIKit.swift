//
//  Button+UIKit.swift
//  slides
//
//  Created by softphone on 12/08/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI


extension UIButton {
    
    /// Called when the screen’s focusedView has been updated to a new view. Use the animation coordinator to schedule focus-related animations in response to the update.
    open override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        print( "\(type(of: self)).didUpdateFocusInContext: focused: \(self.isFocused)" );
        
        super.didUpdateFocus(in: context, with: coordinator)
    }
   
}


struct ButtonFocusableView : UIViewRepresentable {
    
    typealias UIViewType = UIButton
    
    func makeUIView(context: Context) -> UIButton {
        
        return UIButton()
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        
    }
    
    
    
    
}
//struct Button_UIKit_Previews: PreviewProvider {
//    static var previews: some View {
//        Button_UIKit()
//    }
//}
