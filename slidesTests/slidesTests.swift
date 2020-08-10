//
//  slidesTests.swift
//  slidesTests
//
//  Created by softphone on 31/03/16.
//  Copyright © 2016 soulsoftware. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
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
    
    func testFrame() {
        
        let rect1 = CGRect(x: 0,y: 0,width: 100,height: 100)
        
        let rect2 = rect1.offsetBy(dx: 10, dy: 10)
        print( "rect2: \(rect2)")

        
        let rect3 = rect1.inset(by: UIEdgeInsets(top:20, left:30,bottom: -60, right: -30))
        print( "rect2: \(rect3)")
        
        
    }
    func testScan() throws {

        typealias SelectInfo = (key:Int, step:Int)
        
        let stream = Observable.from([1,2,1,1,2,3,3])

        let result = try stream.scan( (key:0, step:0), accumulator: { (last:SelectInfo, item:Int) -> SelectInfo in
            
                let result:SelectInfo = (key:item, step:(last.key == item) ? last.step + 1 : 1 )
            
                return result
            })
            .do( onNext: { (item:SelectInfo) in
                print("SCAN RESULT: \(item)")
            })
            .filter({ (item:SelectInfo) -> Bool in
                return item.step >= 2
            })
            .map({ (key, step) -> Int in
                return key
            })
            .toBlocking()
            .first()

        XCTAssertEqual(result, 1)
    
    }
    
    func testDownload() {
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        
        let url = "http://publications.gbdirect.co.uk/c_book/thecbook.pdf"
        
        let downloadURL = URL(string: url)
        
        XCTAssertNotNil(downloadURL)
        
        let documentDirectoryURL =  try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

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
        
        self.waitForExpectations(timeout: 60) { error in
            
            XCTAssertNil(error, "Something went horribly wrong")
            
        }

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
