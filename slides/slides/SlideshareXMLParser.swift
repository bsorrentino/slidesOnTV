//
//  SlideshareXMLParser.swift
//  slides
//
//  Created by softphone on 03/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import Combine

struct DocumentField {
    
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

class SlideshareItemsParser : NSObject, XMLParserDelegate {
    
    var currentData:(slide:Slideshow, attr:String?)?
    
    var currentError:String?
    
    //@Published private(set) var slides: [Slideshow] = [Slideshow]()
    
    private var subject = PassthroughSubject<Slideshow, Error>()
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "SlideShareServiceError" {
            currentError = ""
            return
        }
        
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
        
        if let err = currentError {
            currentError = err + string
        }
        
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
        
        if currentError != nil { return }
        
        let e = elementName.lowercased()
        
        if e == "slideshow", let data = currentData {

            subject.send(data.slide)
            
            currentData = nil
        }
        else if e == "title" {
            
            if let title =  currentData!.slide[e] {
                currentData!.slide[e] = title.htmlDecoded()
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        if let err = currentError {
            subject.send(completion: .failure(err))
            return
        }
        
        subject.send(completion: .finished)
    }
    
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        subject.send(completion: .failure(parseError))
    }
    
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        subject.send(completion: .failure(validationError))
    }
    
    func parse( _ data:Data! ) -> AnyPublisher<Slideshow,Error> {

        let parser = XMLParser(data: data)
        parser.delegate = self
        
        parser.parse()
        
        return subject.eraseToAnyPublisher()

    }
}
