//
//  String+Extensions.swift
//  slides
//
//  Created by softphone on 03/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import CommonCrypto

// Make String compliant with errors
// @ref https://www.hackingwithswift.com/example-code/language/how-to-throw-errors-using-strings
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

/**
 Hash sting with SHA 1
 
 @ref https://stackoverflow.com/a/25762128/521197
 */
extension String {
    
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined(separator: "")
    }
    
}

/**
 Decode HTML String
 @ref https://stackoverflow.com/a/25607542/521197
 */
extension String {

    init?(htmlEncodedString: String) {

        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        self.init(attributedString.string)

    }

}
