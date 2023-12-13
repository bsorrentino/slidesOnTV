//
//  App+Info.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 08/05/22.
//  Copyright © 2022 bsorrentino. All rights reserved.
//

import Foundation
import UIKit

//
// @see https://www.hackingwithswift.com/example-code/system/how-to-read-your-apps-version-from-your-infoplist-file
//
public func appVersion() -> String {

    if let result = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
        
        if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return "\(result) (\(build))"
        }
        return result
    }
    
    return "no version"
}

public func appName() -> String {
    
    if let result = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
        
        return result
    }
    
    return "KeyChainX"
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
}
