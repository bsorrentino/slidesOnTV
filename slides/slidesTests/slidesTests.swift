//
//  slidesTests.swift
//  slidesTests
//
//  Created by softphone on 03/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import XCTest
import Combine
import OSLog

let log = Logger(subsystem: "org.bsc.slides", category: "main")

class slidesTests: XCTestCase {

    
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSlideshare_query() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expectation = self.expectation(description: "query")
        
        let credentials = try? SlideshareApi.getCredential()
        XCTAssertNotNil(credentials, "credentials not found!")

        let api = SlideshareApi()
        
        let parser = SlideshareItemsParser()
        
        let query = try api.query(credentials: credentials!, query:"swiftui")
            .toGenericError()
            .flatMap( { parser.parse($0.data) } )
            .filter({ $0[SlidehareItem.Format]=="pdf" })
        
        
            query
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("DONE")
                }
                expectation.fulfill()
            },
            receiveValue: {
                print( "title:\($0[SlidehareItem.Title]!) - Format:\($0[SlidehareItem.Format]!)" )
            }).store( in: &subscriptions )
        
        wait( for: [expectation], timeout: 10)
    }

    func testSlideshare_queryById() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expectation = self.expectation(description: "query")
        
        let credentials = try? SlideshareApi.getCredential()
        XCTAssertNotNil(credentials, "credentials not found!")

        let api = SlideshareApi()
        
        let parser = SlideshareItemsParser()
        
        let query = try api.queryById(credentials: credentials!, id:"8071411")
            .toGenericError()
            .flatMap( { parser.parse($0.data) } )
                
        query
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("DONE")
                }
            },
            receiveValue: {
                guard let id = $0[SlidehareItem.ITEMID] else {
                    XCTFail("ID not present")
                    return
                }
                XCTAssertEqual( "8071411", id)
                expectation.fulfill()
            }).store( in: &subscriptions )
        
        wait( for: [expectation], timeout: 10)
    }
    
    func testSlideshareParse() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expectation = self.expectation(description: "query")
        
        let testBundle = Bundle(for: type(of: self))
        
        guard let bundlePath = testBundle.url(forResource: "Slideshow", withExtension: "xml") else {
            throw "cannot find bundle 'Slideshow.xml'"
        }
        
        let data = try Data(contentsOf: bundlePath)
        
        let parser = SlideshareItemsParser()
        
        parser.parse(data).sink(
                receiveCompletion: { print( $0 ) },
                receiveValue: {
                    guard let id = $0[SlidehareItem.ITEMID] else {
                        XCTFail("ID not present")
                        return
                    }
                    XCTAssertEqual( "8071411", id)
                    expectation.fulfill()
                }).store( in: &subscriptions )
        
        wait( for: [expectation], timeout: 10)
    }

    func testJSONArrayDecode() throws {
        
        let decoder = JSONDecoder()
        
        guard let data = "[170,130]".data(using: .utf8) else {
            XCTFail()
            return
        }
        
        let array = try decoder.decode([Int].self, from: data )
        
        XCTAssertEqual( 2, array.count )
        XCTAssertEqual( 170, array[0] )
        XCTAssertEqual( 130, array[1] )
 
    }
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
