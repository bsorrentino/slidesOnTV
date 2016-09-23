//
//  slidesTests.swift
//  slidesTests
//
//  Created by softphone on 31/03/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import XCTest
//@testable import slides

class slidesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    /*
    func testReadBundlePath() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let path = NSBundle.mainBundle().pathForResource("rx1", ofType: "pdf")
        
        XCTAssertNotNil(path)
        
        let url = NSURL(fileURLWithPath: path!)
        
        let doc = OHPDFDocument(URL: url)
        
        XCTAssertNotNil(doc)
        
        XCTAssertEqual(doc.pagesCount, 115, "number of page doesn't match")
    }
    */
    func testDownload() {
        
        let asyncExpectation = expectationWithDescription("longRunningFunction")
        
        let url = "http://publications.gbdirect.co.uk/c_book/thecbook.pdf"
        
        let downloadURL = NSURL(string: url)
        
        XCTAssertNotNil(downloadURL)
        
        let documentDirectoryURL =  try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)

        XCTAssertNotNil(documentDirectoryURL)
        
        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(downloadURL!,
                                                               toDirectory: documentDirectoryURL,
                                                               withName: "test1.pdf",
                                                               progression: { (progress, totalBytesWritten, totalBytesExpectedToWrite) in
                                                                print( "\(progress) - \(totalBytesWritten) - \(totalBytesExpectedToWrite)" )
            }) { (error, location) in
                
                XCTAssertNil(error)
                
                print( "Download completed at location \(location)")
                
                asyncExpectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60) { error in
            
            XCTAssertNil(error, "Something went horribly wrong")
            
        }

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
