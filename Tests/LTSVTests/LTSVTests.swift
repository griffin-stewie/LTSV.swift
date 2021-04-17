import XCTest
@testable import LTSV

final class LTSVTests: XCTestCase {
    func testLTSVParse() {
        let string = "label1:value1\tlabel2:value2"

        let dict = LTSV.parse(row: string)

        XCTAssertEqual(dict.keys.count, 2)
        XCTAssertEqual(dict.values.count, 2)
        XCTAssertEqual(dict["label1"]!, "value1")
        XCTAssertEqual(dict["label2"]!, "value2")
    }

    static var allTests = [
        ("testLTSVParse", testLTSVParse),
    ]
}
