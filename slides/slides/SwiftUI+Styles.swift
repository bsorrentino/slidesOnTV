//
//  SwiftUI+Styles.swift
//  slides
//
//  Created by softphone on 14/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

struct BlueShadowProgressViewStyle: ProgressViewStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .progressViewStyle( LinearProgressViewStyle())
            .foregroundColor(.white)
            .font( .system(size: 16 ).bold() )
            //.shadow(color: Color.blue, radius: 4.0, x: 1.0, y: 2.0)
    }
}
