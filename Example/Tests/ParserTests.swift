import UIKit
import XCTest
@testable import AdyenBarcoder

class ParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWithValidStatusResponse() {
        let data = Data(hex: "0000000d000000128000000100")
        
        let response = Parser().parseResponse(data)
        XCTAssertTrue(response.result)
    }
    
    func testWithInvalidResponseEncoding() {
        let data = "0000000d000000128000000100".data(using: .utf8)!
        
        let response = Parser().parseResponse(data)
        XCTAssertFalse(response.result)
    }
    
    func testWithValidDataResponse() {
        let data = Data(hex: "0000001d0000001180000000000b040134303131343632353632323039")
        
        let response = Parser().parseResponse(data)
        
        XCTAssertTrue(response.result)
        XCTAssertEqual(response.barcode?.codeId, .UPC_EA)
        XCTAssertEqual(response.barcode?.symbolId, .EAN13)
        XCTAssertEqual(response.barcode?.text, "4011462562209")
    }
    
    func testWithEmptyDataResponse() {
        let data = Data(hex: "0000001d000000118000000000")
        
        let response = Parser().parseResponse(data)
        
        XCTAssertFalse(response.result)
    }
}
