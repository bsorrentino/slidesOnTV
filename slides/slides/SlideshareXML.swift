//
//  SlideshareXMLParser.swift
//  slides
//
//  Created by softphone on 03/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import Foundation
import Combine

struct SlideshowsMeta  {
    var Query:String
    var ResultOffset:String?
    var NumResults:Int
    var TotalResults:Int
    
    init( slide:Slideshow ) {
        Query = slide[SlidehareItem.Query]!
        ResultOffset = slide[SlidehareItem.ResultOffset]
        NumResults = Int( slide[SlidehareItem.NumResults]! )!
        TotalResults = Int( slide[SlidehareItem.TotalResults]! )!
    }
}

struct SlideshowsError  {
    var Message:String?
    
    init( slide:Slideshow ) {
        Message = slide[SlidehareItem.Message]
    }
}


class SlideshareItemsParser : NSObject, XMLParserDelegate {
    
    var currentData:(slide:Slideshow, attr:String?)?
    
    var currentError:SlideshowsError?
    var meta:SlideshowsMeta?
    
    
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
        
        if let error = currentError {
            subject.send(completion: .failure( error.Message ?? "Unknow Error"))
            currentError = nil
            return
        }
        
        subject.send(completion: .finished)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        //log.trace( "didStartElement( \(elementName) )" )

        if currentData != nil  {
            
            // currentData!.attr = SlidehareItem.names.contains(elementName.lowercased()) ? elementName.lowercased() : nil
            currentData!.attr = elementName.lowercased()

        }
        else {
            // log.trace( "start \(elementName) - \(attributeDict)")
            
            if( elementName == "Slideshow" ) {
                currentData = (slide:Slideshow(), attr:nil)
            }
            else if( elementName == "Meta") {
                currentData = (slide:Slideshow(), attr:nil)
            }
            else if( elementName == "SlideShareServiceError" ) {
                currentData = (slide:Slideshow(), attr:nil)
            }
        }
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        //log.trace( "didEndElement( \(elementName) )" )
        
        if let data = currentData?.slide {
        
            if elementName == "Slideshow" {
                //log.trace( "send( \(data) )" )
                subject.send(data)
                currentData = nil
            }
            else if elementName == "Meta" {
                meta = SlideshowsMeta(slide: data)
                currentData = nil
            }
            else if( elementName == "SlideShareServiceError" ) {
                log.error( "error \(data)" )
                currentError = SlideshowsError(slide: data)
                currentData = nil
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
