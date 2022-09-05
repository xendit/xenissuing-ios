import XCTest
@testable import Xenissuing

final class XenissuingTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertNotNil(Xenissuing(xenditKey: Data()))
    }
}
