import XCTest
@testable import LTSV

final class LTSVEncoderTests: XCTestCase {
    func testLTSVEncodeSingleRow() throws {
        struct Model: Codable, Equatable {
            let label1: String
            let label2: String
        }

        // let string = "label1:value1\tlabel2:value2"

        let model = Model(label1: "value1", label2: "value2")

        let encoder = LTSVEncoder()
        let result = try encoder.encode(model)


        let decoder = LTSVDecoder()
        let decodedModel = try decoder.decode(Model.self, from: result)


        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVEncodeRows() throws {
        struct Model: Codable, Equatable {
            let label1: String
            let label2: String
        }

        // let string = "label1:value1\tlabel2:value2\nlabel1:value3\tlabel2:value4"


        let models = [
            Model(label1: "value1", label2: "value2"),
            Model(label1: "value3", label2: "value4"),
        ]


        let encoder = LTSVEncoder()
        let result = try encoder.encode(models)

        let decoder = LTSVDecoder()
        let decodedModels = try decoder.decode([Model].self, from: result)

        XCTAssertEqual(models, decodedModels)
    }

    func testLTSVEncodeRowsTheEmptyValueFieldAsNil() throws {
        struct Model: Codable, Equatable {
            let label1: String?
            let label2: String?
        }

        let models = [
            Model(label1: nil, label2: "value2"),
            Model(label1: nil, label2: nil),
        ]

        let encoder = LTSVEncoder()
        let result = try encoder.encode(models)

        let decoder = LTSVDecoder()
        let decodedModels = try decoder.decode([Model].self, from: result)

        XCTAssertEqual(models, decodedModels)
    }

    static var allTests = [
        ("testLTSVEncodeSingleRow", testLTSVEncodeSingleRow),
        ("testLTSVEncodeRows", testLTSVEncodeRows),
        ("testLTSVEncodeRowsTheEmptyValueFieldAsNil", testLTSVEncodeRowsTheEmptyValueFieldAsNil),
    ]
}

