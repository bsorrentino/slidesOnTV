//
//  AppDelegate.swift
//  slides
//
//  Created by softphone on 01/03/2020.
//  Copyright © 2020 bsorrentino. All rights reserved.
//

import SwiftUI
import OSLog

let log = Logger(subsystem: "org.bsc.slides", category: "main")

@main
struct SwiftUITVAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
//            ContentViewTest()
        }
    }
}
