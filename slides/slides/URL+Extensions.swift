//
//  URL+Extensions.swift
//  slides
//
//  Created by Bartolomeo Sorrentino on 21/12/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import UIKit

extension URL {
    static func fromXCAsset(name: String) -> URL? {
        let fileManager = FileManager.default
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
        let url = cacheDirectory.appendingPathComponent("\(name).png")
        let path = url.path
        if !fileManager.fileExists(atPath: path) {
            guard let image = UIImage(named: name), let data = image.pngData() else {return nil}
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
        }
        return url
    }
    
    static func fromXCAsset(systemName: String) -> URL? {
        let fileManager = FileManager.default
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
        let url = cacheDirectory.appendingPathComponent("\(systemName).png")
        let path = url.path
        if !fileManager.fileExists(atPath: path) {
            guard let image = UIImage(systemName: systemName), let data = image.pngData() else {return nil}
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
        }
        return url
    }
}
