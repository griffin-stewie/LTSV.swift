import XCTest
@testable import LTSV

final class LTSVBidirectionTests: XCTestCase {
    func testLTSVBidirectionalSingleRow() throws {
        struct Model: Codable, Equatable {
            let label1: String
            let label2: String
        }

        let model = Model(label1: "value1", label2: "value2")

        let encoder = LTSVEncoder()
        let result = try encoder.encode(model)


        let decoder = LTSVDecoder()
        let decodedModel = try decoder.decode(Model.self, from: result)


        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalRows() throws {
        struct Model: Codable, Equatable {
            let label1: String
            let label2: String
        }

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

    func testLTSVBidirectionalRowsTheEmptyValueFieldAsNil() throws {
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

    func testLTSVBidirectionalRowsSupoortIntFamily() throws {
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

    func testLTSVBidirectionalRowsSupoortFloatingPointFamily() throws {
        struct Model: Codable, Equatable {
            let float: Float
            let floatOptional: Float?
            let floatOptionalNil: Float?
            let float32: Float32
            let float32Optional: Float32?
            let float32OptionalNil: Float32?
            let float64: Float64
            let float64Optional: Float64?
            let float64OptionalNil: Float64?
            let double64: Double
            let doubleOptional: Double?
            let doubleOptionalNil: Double?
        }

        let model = Model(float: 1.0, floatOptional: 1.0, floatOptionalNil: nil, float32: 1.0, float32Optional: 1.0, float32OptionalNil: nil, float64: 1.0, float64Optional: 1.0, float64OptionalNil: nil, double64: 1.0, doubleOptional: 1.0, doubleOptionalNil: nil)

        let encoder = LTSVEncoder()
        let result = try encoder.encode(model)

        let decoder = LTSVDecoder()
        let decodedModel = try decoder.decode(Model.self, from: result)

        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalDateDefferedDateStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        let result = try encoder.encode(model)


        let decoder = LTSVDecoder()
        let decodedModel = try decoder.decode(Model.self, from: result)


        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalDateSecondsSince1970Strategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let result = try encoder.encode(model)


        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decodedModel = try decoder.decode(Model.self, from: result)


        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalDateMilliSecondsSince1970Strategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let result = try encoder.encode(model)


        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let decodedModel = try decoder.decode(Model.self, from: result)


        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalDateISO8601Strategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let result = try encoder.encode(model)


        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedModel = try decoder.decode(Model.self, from: result)


        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalDateGivenDateFormatterStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .formatted(LTSV.dateFormatter)
        let result = try encoder.encode(model)


        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .formatted(LTSV.dateFormatter)
        let decodedModel = try decoder.decode(Model.self, from: result)


        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalDateCustomStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .custom({ (date) -> String in
            return LTSV.dateFormatter.string(from: date)
        })
        let result = try encoder.encode(model)


        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .custom({ (string) -> Date in
            return LTSV.dateFormatter.date(from: string)!
        })
        let decodedModel = try decoder.decode(Model.self, from: result)


        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalDateNginxTimeLocalStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .nginxTimeLocal
        let result = try encoder.encode(model)


        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .nginxTimeLocal
        let decodedModel = try decoder.decode(Model.self, from: result)


        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalBoolDefaultStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Bool?
            let label2: Bool
            let label3: Bool
        }

        let model = Model(label1: nil, label2: true, label3: false)

        let encoder = LTSVEncoder()
        let result = try encoder.encode(model)

        let decoder = LTSVDecoder()
        let decodedModel = try decoder.decode(Model.self, from: result)

        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalBoolCustomStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Bool?
            let label2: Bool
            let label3: Bool
        }

        let model = Model(label1: nil, label2: true, label3: false)

        let encoder = LTSVEncoder()
        encoder.boolEncodingStrategy = .custom({ value in
            value ? "good" : "bad"
        })
        let result = try encoder.encode(model)

        let decoder = LTSVDecoder()
        decoder.boolDecodingStrategy = .custom({ value in
            switch value {
            case "good":
                return true
            case "bad":
                return false
            default:
                return false
            }
        })
        let decodedModel = try decoder.decode(Model.self, from: result)

        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalEnum() throws {

        enum StatusCode: Int, Codable {
            case ok = 200
            case notFound = 404
        }

        struct Model: Codable, Equatable {
            let label1: String
            let label2: String
            let label3: StatusCode
            let label4: StatusCode
        }

        let model = Model(label1: "200", label2: "404", label3: .ok, label4: .notFound)
        let encoder = LTSVEncoder()
        let result = try encoder.encode(model)
        let decoder = LTSVDecoder()
        let decodedModel = try decoder.decode(Model.self, from: result)
        XCTAssertEqual(model, decodedModel)
    }

    func testLTSVBidirectionalStringBasedEnum() throws {

        enum StatusCode: String, Codable {
            case ok = "200"
            case notFound = "404"
        }

        struct Model: Codable, Equatable {
            let label1: String
            let label2: String
            let label3: StatusCode
            let label4: StatusCode
        }

        let model = Model(label1: "200", label2: "404", label3: .ok, label4: .notFound)
        let encoder = LTSVEncoder()
        let result = try encoder.encode(model)
        let decoder = LTSVDecoder()
        let decodedModel = try decoder.decode(Model.self, from: result)
        XCTAssertEqual(model, decodedModel)
    }
}
