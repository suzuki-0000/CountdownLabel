import XCTest
@testable import CountdownLabel

final class CountdownLabelTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CountdownLabel().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
