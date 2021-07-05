//
//  XCode+Utils.swift
//  slides
//
//  Created by softphone on 05/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation

var isInPreviewMode:Bool {
    (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil)
}

#if targetEnvironment(simulator)
  // Simulator!
let isRunningOnSimulator = true
#else
let isRunningOnSimulator = false
#endif

