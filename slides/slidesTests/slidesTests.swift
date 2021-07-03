//
//  slidesTests.swift
//  slidesTests
//
//  Created by softphone on 03/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import XCTest
import Combine

class slidesTests: XCTestCase {

    var cancellable: AnyCancellable?
    var cancellable2: AnyCancellable?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testSlideshare() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expectation = self.expectation(description: "query")
        
        let credentials = try? SlideshareApi.getCredential()
        XCTAssertNotNil(credentials, "credentials not found!")

        let api = SlideshareApi()
        
        let query = try? api.queryById(credentials: credentials!, id:"8071411")
        XCTAssertNotNil(query, "creation query error")
        
        cancellable =
            query!
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("DONE")
                }
                expectation.fulfill()
            },
            receiveValue: { (data, response) in
                if let string = String(data: data, encoding: .utf8) {
                    print(string)
                }
            })
        
        wait( for: [expectation], timeout: 10)
    }
    
    func testSlideshareParse() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expectation = self.expectation(description: "query")
        
        let credentials = try? SlideshareApi.getCredential()
        XCTAssertNotNil(credentials, "credentials not found!")

        let api = SlideshareApi()
        
        let query = try? api.queryById(credentials: credentials!, id:"8071411")
        XCTAssertNotNil(query, "creation query error")

        let parser = SlideshareItemsParser()
        
        cancellable =
            query!
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
                let result = parser.parse( $0.data )
                    
                
                self.cancellable2 = result.sink(receiveCompletion: { completion in }, receiveValue: { print( $0 )})

            })
        
        wait( for: [expectation], timeout: 10)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
