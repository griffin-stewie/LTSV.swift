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

    func testLTSVDecodeRowsSupoortIntFamily() throws {
        struct Model: Codable {
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

        let string = "int:1\tintOptional:\tint8:1\tint8Optional:\tint16:1\tint16Optional:\tint32:1\tint32Optional:\tint64:1\tint64Optional:\tuInt:1\tuIntOptional:\tuInt8:1\tuInt8Optional:\tuInt16:1\tuInt16Optional:\tuInt32:1\tuInt32Optional:\tuInt64:1\tuInt64Optional:"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertEqual(model.int, 1)
        XCTAssertNil(model.intOptional)
        XCTAssertEqual(model.int8, 1)
        XCTAssertNil(model.int8Optional)
        XCTAssertEqual(model.int16, 1)
        XCTAssertNil(model.int16Optional)
        XCTAssertEqual(model.int32, 1)
        XCTAssertNil(model.int32Optional)
        XCTAssertEqual(model.int64, 1)
        XCTAssertNil(model.int64Optional)
        XCTAssertEqual(model.uInt, 1)
        XCTAssertNil(model.uIntOptional)
        XCTAssertEqual(model.uInt8, 1)
        XCTAssertNil(model.uInt8Optional)
        XCTAssertEqual(model.uInt16, 1)
        XCTAssertNil(model.uInt16Optional)
        XCTAssertEqual(model.uInt32, 1)
        XCTAssertNil(model.uInt32Optional)
        XCTAssertEqual(model.uInt64, 1)
        XCTAssertNil(model.uInt64Optional)
    }

    func testLTSVDecodeRowsSupoortFloatingPointFamily() throws {
        struct Model: Codable {
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

        let string = "float:1.0\tfloatOptional:1.0\tfloatOptionalNil:\tfloat32:1.0\tfloat32Optional:1.0\tfloat32OptionalNil:\tfloat64:1.0\tfloat64Optional:1.0\tfloat64OptionalNil:\tdouble64:1.0\tdoubleOptional:1.0\tdoubleOptionalNil:"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertEqual(model.float, 1.0)
        XCTAssertEqual(model.floatOptional, 1.0)
        XCTAssertNil(model.floatOptionalNil)
        XCTAssertEqual(model.float32, 1.0)
        XCTAssertEqual(model.float32Optional, 1.0)
        XCTAssertNil(model.float32OptionalNil)
        XCTAssertEqual(model.float64, 1.0)
        XCTAssertEqual(model.float64Optional, 1.0)
        XCTAssertNil(model.float64OptionalNil)
        XCTAssertEqual(model.double64, 1.0)
        XCTAssertEqual(model.doubleOptional, 1.0)
        XCTAssertNil(model.doubleOptionalNil)
    }

    func testLTSVDecodeDateDefferedDateStrategy() throws {
        struct Model: Codable {
            let label1: Date
            let label2: Date?
        }

        let string = "label1:640414453.0\tlabel2:"

        print(TimeZone.current)

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        let date = Date(timeIntervalSinceReferenceDate: 640414453.0)

        XCTAssertEqual(model.label1, date)
        XCTAssertNil(model.label2)
    }

    func testLTSVDecodeDateSecondsSince1970Strategy() throws {
        struct Model: Codable {
            let label1: Date
            let label2: Date?
        }

        let string = "label1:1618721653.0\tlabel2:"

        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let model = try decoder.decode(Model.self, from: string)

        let date = Date(timeIntervalSince1970: 1618721653.0)

        XCTAssertEqual(model.label1, date)
        XCTAssertNil(model.label2)
    }

    func testLTSVDecodeDateMilliSecondsSince1970Strategy() throws {
        struct Model: Codable {
            let label1: Date
            let label2: Date?
        }

        let string = "label1:1618721653000.0\tlabel2:"

        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let model = try decoder.decode(Model.self, from: string)

        let date = Date(timeIntervalSince1970: 1618721653.0)

        XCTAssertEqual(model.label1, date)
        XCTAssertNil(model.label2)
    }

    func testLTSVDecodeDateISO8601Strategy() throws {
        if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            struct Model: Codable {
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

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = .withInternetDateTime

            let string = "label1:\(formatter.string(from: date))\tlabel2:"

            let decoder = LTSVDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let model = try decoder.decode(Model.self, from: string)

            XCTAssertEqual(model.label1, date)
            XCTAssertNil(model.label2)
        }
    }

    func testLTSVDecodeDateGivenDateFormatterStrategy() throws {
        struct Model: Codable {
            let label1: Date
            let label2: Date?
        }

        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            formatter.dateFormat = "[dd/MMM/yyyy:HH:mm:ss Z]"
            return formatter
        }()

        let string = "label1:[18/Apr/2021:13:54:13 +0900]\tlabel2:"

        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let model = try decoder.decode(Model.self, from: string)

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

        XCTAssertEqual(model.label1, date)
        XCTAssertNil(model.label2)
    }

    func testLTSVDecodeDateCustomStrategy() throws {
        struct Model: Codable {
            let label1: Date
            let label2: Date?
        }

        let string = "label1:[18/Apr/2021:13:54:13 +0900]\tlabel2:"

        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .custom({ (string) -> Date in
            return LTSV.dateFormatter.date(from: string)!
        })
        let model = try decoder.decode(Model.self, from: string)

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

        print("モデルのDate: \(model.label1)")
        print("期待値のDate: \(date)")
        XCTAssertEqual(model.label1, date)
        XCTAssertNil(model.label2)
    }

    func testLTSVDecodeDateNginxTimeLocalStrategy() throws {
        struct Model: Codable {
            let label1: Date
            let label2: Date?
        }

        let string = "label1:[18/Apr/2021:13:54:13 +0900]\tlabel2:"

        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .nginxTimeLocal
        let model = try decoder.decode(Model.self, from: string)

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

        XCTAssertEqual(model.label1, date)
        XCTAssertNil(model.label2)
    }

    func testLTSVDecodeBoolDefaultStrategy() throws {
        struct Model: Codable {
            let label1: Bool?
            let label2: Bool
            let label3: Bool
            let label4: Bool
            let label5: Bool
        }

        let string = "label1:\tlabel2:true\tlabel3:false\tlabel4:1\tlabel5:0"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertNil(model.label1)
        XCTAssertTrue(model.label2)
        XCTAssertFalse(model.label3)
        XCTAssertTrue(model.label4)
        XCTAssertFalse(model.label5)
    }

    func testLTSVDecodeBoolCustomStrategy() throws {
        struct Model: Codable {
            let label1: Bool?
            let label2: Bool
            let label3: Bool
            let label4: Bool
        }

        let string = "label1:\tlabel2:👍\tlabel3:👎🏻\tlabel4:👎"

        let decoder = LTSVDecoder()
        decoder.boolDecodingStrategy = .custom({ value in
            if value == "👍" {
                return true
            } else if value == "👎🏻" {
                return false
            } else {
                return false
            }
        })
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertNil(model.label1)
        XCTAssertTrue(model.label2)
        XCTAssertFalse(model.label3)
        XCTAssertFalse(model.label4)
    }

    func testLTSVDecodeEnum() throws {

        enum StatusCode: Int, Codable {
            case ok = 200
            case notFound = 404
        }

        struct Model: Codable {
            let label1: String
            let label2: String
            let label3: StatusCode
            let label4: StatusCode
            let label5: StatusCode?
        }

        let string = "label1:200\tlabel2:404\tlabel3:200\tlabel4:404\tlabel5:"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertEqual(model.label1, "200")
        XCTAssertEqual(model.label2, "404")
        XCTAssertEqual(model.label3, .ok)
        XCTAssertEqual(model.label4, .notFound)
        XCTAssertNil(model.label5)
    }

    func testLTSVDecodeStringBasedEnum() throws {

        enum StatusCode: String, Codable {
            case ok = "200"
            case notFound = "404"
        }

        struct Model: Codable {
            let label1: String
            let label2: String
            let label3: StatusCode
            let label4: StatusCode?
        }

        let string = "label1:200\tlabel2:404\tlabel3:200\tlabel4:"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertEqual(model.label1, "200")
        XCTAssertEqual(model.label2, "404")
        XCTAssertEqual(model.label3, .ok)
        XCTAssertNil(model.label4)
    }

    func testLTSVDecodeDoubleBasedEnum() throws {

        enum StatusCode: Double, Codable {
            case ok = 200
            case notFound = 404
        }

        struct Model: Codable {
            let label1: String
            let label2: String
            let label3: StatusCode
            let label4: StatusCode?
        }

        let string = "label1:200\tlabel2:404\tlabel3:200\tlabel4:"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertEqual(model.label1, "200")
        XCTAssertEqual(model.label2, "404")
        XCTAssertEqual(model.label3, .ok)
        XCTAssertNil(model.label4)
    }

    func testLTSVDecodeFloatBasedEnum() throws {

        enum StatusCode: Float, Codable {
            case ok = 200
            case notFound = 404
        }

        struct Model: Codable {
            let label1: String
            let label2: String
            let label3: StatusCode
            let label4: StatusCode?
        }

        let string = "label1:200\tlabel2:404\tlabel3:200\tlabel4:"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertEqual(model.label1, "200")
        XCTAssertEqual(model.label2, "404")
        XCTAssertEqual(model.label3, .ok)
        XCTAssertNil(model.label4)
    }

    func testLTSVDecodeFloat32BasedEnum() throws {

        enum StatusCode: Float32, Codable {
            case ok = 200
            case notFound = 404
        }

        struct Model: Codable {
            let label1: String
            let label2: String
            let label3: StatusCode
            let label4: StatusCode?
        }

        let string = "label1:200\tlabel2:404\tlabel3:200\tlabel4:"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertEqual(model.label1, "200")
        XCTAssertEqual(model.label2, "404")
        XCTAssertEqual(model.label3, .ok)
        XCTAssertNil(model.label4)
    }

    func testLTSVDecodeFloat64BasedEnum() throws {

        enum StatusCode: Float64, Codable {
            case ok = 200
            case notFound = 404
        }

        struct Model: Codable {
            let label1: String
            let label2: String
            let label3: StatusCode
            let label4: StatusCode?
        }

        let string = "label1:200\tlabel2:404\tlabel3:200\tlabel4:"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        XCTAssertEqual(model.label1, "200")
        XCTAssertEqual(model.label2, "404")
        XCTAssertEqual(model.label3, .ok)
        XCTAssertNil(model.label4)
    }
}

