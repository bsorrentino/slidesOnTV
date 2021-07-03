//
//  String+Extensions.swift
//  slides
//
//  Created by softphone on 03/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    func htmlDecoded() -> String {
        
        guard (self != "") else { return self }
        
        var _self = self;
        if let v = self.removingPercentEncoding  {
            _self = v
        }
        return _self
            .replacingOccurrences( of: "&quot;", with: "\"")
            .replacingOccurrences( of: "&amp;" , with: "&" )
            .replacingOccurrences( of: "&apos;",    with: "'" )
            .replacingOccurrences( of: "&lt;",      with: "<" )
            .replacingOccurrences(  of: "&gt;",      with: ">" )
    }
    
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined(separator: "")
    }
    
//    private func SHA1( _ s:String! ) -> String {
//        let data = s.data(using: String.Encoding.utf8)!
//
//        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
//
//        CC_SHA1((data as NSData).bytes, CC_LONG(data.count), &digest)
//
//        let hexBytes = digest.map { String(format: "%02hhx", $0) }
//
//        return hexBytes.joined(separator: "")
//    }

}

// Make String compliant with errors
// @ref https://www.hackingwithswift.com/example-code/language/how-to-throw-errors-using-strings
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}


