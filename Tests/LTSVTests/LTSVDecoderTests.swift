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

    func testLTSVDecodeDateDefferedDateStrategy() throws {
        struct Model: Codable {
            let label1: Date
            let label2: Date?
        }

        let string = "label1:640414453.0\tlabel2:"

        let decoder = LTSVDecoder()
        let model = try decoder.decode(Model.self, from: string)

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

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

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

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

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

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

        let string = "label1:[18/Apr/2021:13:54:13 +0900]\tlabel2:"

        let decoder = LTSVDecoder()
        decoder.dateDecodingStrategy = .formatted(LTSV.dateFormatter)
        let model = try decoder.decode(Model.self, from: string)

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
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
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

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
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

        XCTAssertEqual(model.label1, date)
        XCTAssertNil(model.label2)
    }

    static var allTests = [
        ("testLTSVDecodeSingleRow", testLTSVDecodeSingleRow),
        ("testLTSVDecodeRows", testLTSVDecodeRows),
        ("testLTSVDecodeRowsTheEmptyValueFieldAsNil", testLTSVDecodeRowsTheEmptyValueFieldAsNil),
        ("testLTSVDecodeRowsSupoortIntFamily", testLTSVDecodeRowsSupoortIntFamily),
        ("testLTSVDecodeDateDefferedDateStrategy", testLTSVDecodeDateDefferedDateStrategy),
        ("testLTSVDecodeDateSecondsSince1970Strategy", testLTSVDecodeDateSecondsSince1970Strategy),
        ("testLTSVDecodeDateMilliSecondsSince1970Strategy", testLTSVDecodeDateMilliSecondsSince1970Strategy),
        ("testLTSVDecodeDateISO8601Strategy", testLTSVDecodeDateISO8601Strategy),
        ("testLTSVDecodeDateNginxTimeLocalStrategy", testLTSVDecodeDateNginxTimeLocalStrategy),
        ("testLTSVDecodeDateGivenDateFormatterStrategy", testLTSVDecodeDateGivenDateFormatterStrategy),
        ("testLTSVDecodeDateCustomStrategy", testLTSVDecodeDateCustomStrategy),
    ]
}

