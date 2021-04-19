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

    func testLTSVEncodeRowsSupoortIntFamily() throws {
        struct Model: Codable, Equatable {
            let int: Int
            let intOptional: Int?
            let int8: Int8
            let int8Optional: Int8?
            let int16: Int16
            let int16Optional: Int16?
            let int32: Int32
            let int32Optional: Int32?
            let int64: Int64
            let int64Optional: Int64?
            let uInt: UInt
            let uIntOptional: UInt?
            let uInt8: UInt8
            let uInt8Optional: UInt8?
            let uInt16: UInt16
            let uInt16Optional: UInt16?
            let uInt32: UInt32
            let uInt32Optional: UInt32?
            let uInt64: UInt64
            let uInt64Optional: UInt64?
        }

        let models = [
            Model(int: -1, intOptional: nil, int8: 1, int8Optional: nil, int16: 1, int16Optional: nil, int32: 1, int32Optional: nil, int64: 1, int64Optional: nil, uInt: 1, uIntOptional: nil, uInt8: 1, uInt8Optional: nil, uInt16: 1, uInt16Optional: nil, uInt32: 1, uInt32Optional: nil, uInt64: 1, uInt64Optional: 100000),
            Model(int: -1, intOptional: 1, int8: 1, int8Optional: 1, int16: 1, int16Optional: nil, int32: 1, int32Optional: nil, int64: 1, int64Optional: nil, uInt: 1, uIntOptional: nil, uInt8: 1, uInt8Optional: nil, uInt16: 1, uInt16Optional: nil, uInt32: 1, uInt32Optional: nil, uInt64: 1, uInt64Optional: 100000),
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

