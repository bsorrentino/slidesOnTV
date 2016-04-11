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


private func SHA1( s:String! ) -> String {
    let data = s.dataUsingEncoding(NSUTF8StringEncoding)!
    
    var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
    
    CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
    
    let hexBytes = digest.map { String(format: "%02hhx", $0) }
    
    return hexBytes.joinWithSeparator("")
}

func slideshareSearch( apiKey apiKey:String, sharedSecret:String, what:String ) ->  Observable<NSData> {
    
    let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
    
    let ts = String(NSDate().timeIntervalSince1970)
    
    let ss = String(format: "%@%@", sharedSecret, ts)
    
    let hash = SHA1(ss)
    
    let params:Dictionary<String,String> = [
        "api_key":apiKey,
        "ts": ts,
        "hash": hash,
        "what":what,
        "download":"0",
        "fileformat": "pdf"
    ]
    
    let queryString =  params.map { (key, value) -> String in
        let percentEscapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)!
        let percentEscapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)!
        return "\(percentEscapedKey)=\(percentEscapedValue)"
        }.joinWithSeparator("&")
    
    let requestURL = NSURL(string: String(format:"https://www.slideshare.net/api/2/search_slideshows?q=%@", queryString))!
    
    let request = NSURLRequest(URL: requestURL)
    
    return NSURLSession.sharedSession().rx_data(request)
    
}


typealias Slideshow = Dictionary<String,String>

class SlideshareItemsParser : NSObject, NSXMLParserDelegate {
    
    var currentData:(slide:Slideshow, attr:String?)?
    
    var subject = PublishSubject<Slideshow>()
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        
        if currentData != nil  {
            
            switch( elementName.lowercaseString ) {
            case "title", "thumbnailsmallurl", "thumbnailxlargeurl", "thumbnailxxlargeurl", "created", "updated", "language", "downloadurl" :
                currentData!.attr = elementName.lowercaseString
                break
            default:
                currentData!.attr = nil
                break
                
            }
        }
        else {
            
            if( elementName == "Slideshow" ) {
                //print( "start \(elementName) - \(attributeDict)")
                currentData = (slide:Slideshow(), attr:nil)
            }
        }
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if let data = currentData, let attr = data.attr {
    
            if let v = data.slide[attr] {

                currentData!.slide[attr] = v + string
                
            }
            else {
                currentData!.slide[attr] = string
                
            }
            
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Slideshow", let data = currentData {
            
            subject.onNext(data.slide)
            
            currentData = nil

            //print( "\(data.slide)")
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        subject.onCompleted()
    }
    
    func rx_parse( data:NSData! ) -> Observable<Slideshow> {
        
        return Observable.create{ observer in
            
            let parser = NSXMLParser(data: data)
            parser.delegate = self
            
            let subscription = self.subject.subscribe(observer);
            
            parser.parse()

            return AnonymousDisposable {
                //print("Disposed")
                subscription.dispose()
            }
        }
    }
}

