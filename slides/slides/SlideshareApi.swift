//
//  SlideshareApi.swift
//  slides
//
//  Created by softphone on 03/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import CommonCrypto

typealias Slideshow = [String:String]


class SlideshareApi /*: ObservableObject */ {
    
    // @Published var presentation = [Slideshow]()
    
    struct Credentials {
        var apikey:String
        var ssecret:String
    }

    enum CredentialError: Error {
        case NotProvided(String)
        
    }
    
    enum RequestError: Error {
        case CreationURL
    }
    
    private let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")

    private func prepareQueryString( credentials:Credentials, _ params:[String:String] ) -> String
    {
        
        let ts = String(Date().timeIntervalSince1970)
        
        let ss = String(format: "%@%@", credentials.ssecret, ts)

        var result = [
            "api_key":credentials.apikey,
            "ts":ts,
            "hash":ss.sha1()
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

    static func getCredential() throws -> Credentials  {
    
        guard let bundlePath = Bundle.main.path(forResource: "slideshare", ofType: "plist") else {
            throw CredentialError.NotProvided("cannot find bundle 'slideshare.plist'")
        }
        
        guard let credentials = NSDictionary(contentsOfFile: bundlePath ) else {
            throw  CredentialError.NotProvided("cannot load credential from bundle 'slideshare.plist'")
        }
        
        guard let apikey = credentials["apiKey"] as? String else {
            throw CredentialError.NotProvided("cannot find 'apiKey' in bundle 'slideshare.plist'")
            
        }
        guard let ssecret = credentials["sharedSecret"]  as? String else {
            throw CredentialError.NotProvided("cannot find 'sharedSecret' in bundle 'slideshare.plist'")
            
        }
        
        return Credentials( apikey:apikey, ssecret:ssecret)
    }
    
    func queryById( credentials:Credentials, id:String ) throws -> URLSession.DataTaskPublisher {
        
        let qs = prepareQueryString( credentials:credentials, [
                                        "slideshow_id":id,
                                        "slideshow_url":""
                                    ])
        
        
        guard let requestURL = URL(string:"https://www.slideshare.net/api/2/get_slideshow?\(qs)" ) else
        {
            throw RequestError.CreationURL
        }
        
        
        let request = URLRequest(url: requestURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        return URLSession.shared.dataTaskPublisher(for: request)
    }

    func query( credentials:Credentials, query:String ) throws ->  URLSession.DataTaskPublisher {
        
        let qs = prepareQueryString( credentials:credentials, [
                                        "q":query,
                                        //"what":"tag",
                                        "fileformat": "pdf", // seems that doesn't work
                                        "format": "pdf", // seems that doesn't work
                                        "download":"0",
                                        "items_per_page":"50",
                                        "sort": "latest"
                                        //"sort":"latest",
                                        //"file_type":"presentations"
                                    ])
        
        guard let requestURL = URL(string: "https://www.slideshare.net/api/2/search_slideshows?\(qs)" ) else
        {
            throw RequestError.CreationURL
        }

        let request = URLRequest(url: requestURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)

        return URLSession.shared.dataTaskPublisher(for: request)
    }

}
