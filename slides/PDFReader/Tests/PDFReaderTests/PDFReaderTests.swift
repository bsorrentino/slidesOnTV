import XCTest
@testable import PDFReader

final class PDFReaderTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PDFReader().text, "Hello, World!")
    }
}
