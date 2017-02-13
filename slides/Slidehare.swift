//
//  Slidehare.swift
//  slideshare
//
//  Created by softphone on 10/04/16.
//  Copyright © 2016 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


extension String {
    func htmlDecoded()->String {
        
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
}

private func SHA1( _ s:String! ) -> String {
    let data = s.data(using: String.Encoding.utf8)!
    
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    
    CC_SHA1((data as NSData).bytes, CC_LONG(data.count), &digest)
    
    let hexBytes = digest.map { String(format: "%02hhx", $0) }
    
    return hexBytes.joined(separator: "")
}

func slideshareSearch( apiKey:String, sharedSecret:String, query:String ) ->  Observable<Data> {
    
    let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
    
    let ts = String(Date().timeIntervalSince1970)
    
    let ss = String(format: "%@%@", sharedSecret, ts)
    
    let hash = SHA1(ss)
    
    let params:Dictionary<String,String> = [
        "q":query,
        "api_key":apiKey,
        "ts": ts,
        "hash": hash,
        //"what":"tag",
        "fileformat": "pdf", // seems that doesn't work
        "download":"0",
        //"sort":"latest",
        //"file_type":"presentations"
    ]
    
    let queryString =  params.map { (key, value) -> String in
        let percentEscapedKey = key.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
        let percentEscapedValue = value.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
        return "\(percentEscapedKey)=\(percentEscapedValue)"
        }.joined(separator: "&")
    
    let requestURL = URL(string: String(format:"https://www.slideshare.net/api/2/search_slideshows?%@", queryString))!
    
    //print( "requestURL\n\(requestURL)!")

    let request = URLRequest(url: requestURL)
    
    return URLSession.shared.rx.data(request: request)
    
}


typealias Slideshow = Dictionary<String,String>

class SlideshareItemsParser : NSObject, XMLParserDelegate {
    
    var currentData:(slide:Slideshow, attr:String?)?
    
    var subject = PublishSubject<Slideshow>()
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        let properties = [
            "title",
            "thumbnailsmallurl",
            "thumbnailxlargeurl",
            "thumbnailxxlargeurl",
            "created",
            "updated",
            "language",
            "format",
            "downloadurl"
        ]
        
        if currentData != nil  {
            
            currentData!.attr = properties.contains(elementName.lowercased()) ? elementName.lowercased() : nil

        }
        else {
            
            if( elementName == "Slideshow" ) {
                //print( "start \(elementName) - \(attributeDict)")
                currentData = (slide:Slideshow(), attr:nil)
            }
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if let data = currentData, let attr = data.attr {
    
            if let v = data.slide[attr] {

                currentData!.slide[attr] = v + string
                
            }
            else {
                currentData!.slide[attr] = string
                
            }
            
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        let e = elementName.lowercased()
        
        if e == "slideshow", let data = currentData {

            subject.onNext(data.slide)
            
            currentData = nil
        }
        else if e == "title" {
            
            if let title =  currentData!.slide[e] {
                currentData!.slide[e] = title.htmlDecoded()
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        subject.onCompleted()
    }
    
    func rx_parse( _ data:Data! ) -> Observable<Slideshow> {
        
        //let ss = String(data: data!, encoding: .utf8) ; print( "parse \(ss)")
        
        return Observable.create{ observer in
            
            let parser = XMLParser(data: data)
            parser.delegate = self
            
            let subscription = self.subject.subscribe(observer);
            
            parser.parse()

            return Disposables.create(with: {
                //print("Disposed")
                subscription.dispose()
            })
        }
    }
}

