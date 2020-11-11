import XCTest
@testable import UnionFind

final class UnionFindTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(UnionFind().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
