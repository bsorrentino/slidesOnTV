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

class DocumentField {
    
    static let Title            = "title"
    static let DownloadUrl      = "downloadurl"
    static let ID               = "id"
    static let URL              = "url" // permalink
    static let Created          = "created"
    static let Updated          = "updated"
    static let Format           = "format"
    static let Language         = "language"
    static let ThumbnailS       = "thumbnailsmallurl"
    static let ThumbnailXL      = "thumbnailxlargeurl"
    static let ThumbnailXXL     = "thumbnailxxlargeurl"
    
    static let names = [
        Title,
        DownloadUrl,
        ID,
        URL,
        Updated,
        Format,
        ThumbnailXL,
        ThumbnailXXL,
        ThumbnailS,
        Created,
        Language
    ]

}


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

private let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")

private func prepareQueryString( apiKey:String,
                      sharedSecret:String,
                      _ params:[String:String] ) -> String
{
    
    let ts = String(Date().timeIntervalSince1970)
    
    let ss = String(format: "%@%@", sharedSecret, ts)
    
    let hash =  SHA1(ss)

    var result = [
        "api_key":apiKey,
        "ts":ts,
        "hash":hash
    ]
    for (k, v) in params {
        result[k] = v
    }
    
    let queryString =  result.map { (key, value) -> String in
        let percentEscapedKey = key.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
        let percentEscapedValue = value.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
        return "\(percentEscapedKey)=\(percentEscapedValue)"
        }.joined(separator: "&")

    return queryString
}

typealias SlideshareCredentials = (apikey:String, ssecret:String)

func rxSlideshareCredentials() -> Single<SlideshareCredentials> {
    guard let bundlePath = Bundle.main.path(forResource: "slideshare", ofType: "plist") else {
        return Single.error( "cannot find bundle 'slideshare.plist'")
    }
    
    guard let credentials = NSDictionary(contentsOfFile: bundlePath ) else {
        return Single.error( "cannot load credential from bundle 'slideshare.plist'")
    }
    
    guard let apikey = credentials["apiKey"] as? String else {
        return Single.error( "cannot find 'apiKey' in bundle 'slideshare.plist'")
        
    }
    guard let ssecret = credentials["sharedSecret"]  as? String else {
        return Single.error( "cannot find 'sharedSecret' in bundle 'slideshare.plist'")
        
    }
    
    return Single.just( (apikey:apikey, ssecret:ssecret))

}

func rxSlideshareGet( credentials:SlideshareCredentials, id:String ) -> Single<Data> {
    
    let qs = prepareQueryString( apiKey:credentials.apikey,
                                 sharedSecret:credentials.ssecret,
                            [
                                    "slideshow_id":id,
                                    "slideshow_url":""
                            ])
    
    
    guard let requestURL = URL(string: String(format:"https://www.slideshare.net/api/2/get_slideshow?%@", qs)) else
    {
        return Single.error( "error creating requestURL" )
    }
    
    
    let request = URLRequest(url: requestURL)
    
    return URLSession.shared.rx.data(request: request).asSingle()
}

func rxSlideshareSearch( apiKey:String, sharedSecret:String, query:String ) ->  Observable<Data> {
    
    let qs = prepareQueryString( apiKey:apiKey,
                                 sharedSecret:sharedSecret,
                                 [
                                    "q":query,
                                    //"what":"tag",
                                    "fileformat": "pdf", // seems that doesn't work
                                    "download":"0",
                                    //"sort":"latest",
                                    //"file_type":"presentations"
                                ])
    
    guard let requestURL = URL(string: String(format:"https://www.slideshare.net/api/2/search_slideshows?%@", qs)) else
    {
        return Observable.error( "error creating requestURL" )
    }

    let request = URLRequest(url: requestURL)
    
    return URLSession.shared.rx.data(request: request)
    
}


typealias Slideshow = [String:String]

class SlideshareItemsParser : NSObject, XMLParserDelegate {
    
    var currentData:(slide:Slideshow, attr:String?)?
    
    var subject = PublishSubject<Slideshow>()
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        
        if currentData != nil  {
            
            currentData!.attr = DocumentField.names.contains(elementName.lowercased()) ? elementName.lowercased() : nil

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

