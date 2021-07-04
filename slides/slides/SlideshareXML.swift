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
    
    private var subject = PassthroughSubject<Slideshow, Error>()
    
    private func escapeAttribute( e:String ) -> String? {
        guard let data = currentData, let value =  data.slide[e] else { return nil }
            
        if( e == "title" ) {
            
            if let decoded = String( htmlEncodedString: value) {
                return decoded.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        if let err = currentError {
            subject.send(completion: .failure(err))
            return
        }
        
        subject.send(completion: .finished)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        //log.trace( "didStartElement( \(elementName) )" )

        if elementName == "SlideShareServiceError" {
            currentError = ""
            return
        }
        
        if currentData != nil  {
            
            currentData!.attr = DocumentField.names.contains(elementName.lowercased()) ? elementName.lowercased() : nil

        }
        else {
            
            if( elementName == "Slideshow" ) {
                //log.trace( "start \(elementName) - \(attributeDict)")
                currentData = (slide:Slideshow(), attr:nil)
            }
        }
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        //log.trace( "didEndElement( \(elementName) )" )
        
        if currentError != nil { return }
        
        let e = elementName.lowercased()
        
        if let data = currentData {
        
            if e == "slideshow" {

                //log.trace( "didEndElement send( \(data.slide) )" )
                subject.send(data.slide)

                currentData = nil
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
            currentData!.slide[attr] = escapeAttribute(e: attr)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        log.error("parseErrorOccurred")
        
        subject.send(completion: .failure(parseError))
    }
    
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        subject.send(completion: .failure(validationError))
    }
    
    func parse( _ data:Data ) -> AnyPublisher<Slideshow,Error> {

        subject.handleEvents(receiveSubscription:  { s in
            DispatchQueue.main.async {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        }).eraseToAnyPublisher()
    }

    
}
