//
//  App+Info.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 08/05/22.
//  Copyright © 2022 bsorrentino. All rights reserved.
//

import Foundation


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
