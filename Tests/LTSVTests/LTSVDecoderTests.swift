import XCTest
@testable import LTSV

final class LTSVDecoderTests: XCTestCase {
    func testLTSVDecodeSingleRow() throws {
        struct Model: Codable {
            let label1: String
            let label2: String
        }

        let string = "label1:value1\tlabel2:value2"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertEqual(model.label1, "value1")
        XCTAssertEqual(model.label2, "value2")
    }

    func testLTSVDecodeRows() throws {
        struct Model: Codable {
            let label1: String
            let label2: String
        }

        let string = "label1:value1\tlabel2:value2\nlabel1:value3\tlabel2:value4"

        let decoder = LTSVDecoder()
        let models = try decoder.decode([Model].self, from: string)

        let model = models[0]
        XCTAssertEqual(model.label1, "value1")
        XCTAssertEqual(model.label2, "value2")

        let model2 = models[1]
        XCTAssertEqual(model2.label1, "value3")
        XCTAssertEqual(model2.label2, "value4")
    }

    func testLTSVDecodeRowsTheEmptyValueFieldAsNil() throws {
        struct Model: Codable {
            let label1: String?
            let label2: String?
        }

        let string = "label1:\tlabel2:value2"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertNil(model.label1)
        XCTAssertEqual(model.label2!, "value2")
    }

    func testLTSVDecodeRowsSupoortInt() throws {
        struct Model: Codable {
            let label1: String?
            let label2: String?
            let status: Int
            let size: Int?
        }

        let string = "label1:\tlabel2:value2\tstatus:200\tsize:"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertNil(model.label1)
        XCTAssertEqual(model.label2!, "value2")
        XCTAssertEqual(model.status, 200)
        XCTAssertNil(model.size)
    }


    static var allTests = [
        ("testLTSVDecodeSingleRow", testLTSVDecodeSingleRow),
        ("testLTSVDecodeRows", testLTSVDecodeRows),
        ("testLTSVDecodeRowsTheEmptyValueFieldAsNil", testLTSVDecodeRowsTheEmptyValueFieldAsNil),
        ("testLTSVDecodeRowsSupoortInt", testLTSVDecodeRowsSupoortInt),
    ]
}

