import XCTest
@testable import LTSV

final class LTSVEncoderTests: XCTestCase {
    func testLTSVEncodeSingleRow() throws {
        struct Model: Codable, Equatable {
            let label1: String
            let label2: String
        }

        let model = Model(label1: "value1", label2: "value2")

        let encoder = LTSVEncoder()
        let result = try encoder.encode(model)


        let expects = "label1:value1\tlabel2:value2"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeRows() throws {
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

        let expects = """
            label1:value1\tlabel2:value2
            label1:value3\tlabel2:value4
            """

        XCTAssertEqual(result, expects)
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

        let expects = """
            label1:\tlabel2:value2
            label1:\tlabel2:
            """

        XCTAssertEqual(result, expects)
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

        let expects = """
            int:-1\tintOptional:\tint8:1\tint8Optional:\tint16:1\tint16Optional:\tint32:1\tint32Optional:\tint64:1\tint64Optional:\tuInt:1\tuIntOptional:\tuInt8:1\tuInt8Optional:\tuInt16:1\tuInt16Optional:\tuInt32:1\tuInt32Optional:\tuInt64:1\tuInt64Optional:100000
            int:-1\tintOptional:1\tint8:1\tint8Optional:1\tint16:1\tint16Optional:\tint32:1\tint32Optional:\tint64:1\tint64Optional:\tuInt:1\tuIntOptional:\tuInt8:1\tuInt8Optional:\tuInt16:1\tuInt16Optional:\tuInt32:1\tuInt32Optional:\tuInt64:1\tuInt64Optional:100000
            """

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeDateDefferedDateStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        let result = try encoder.encode(model)

        let expects = "label1:640414453.0\tlabel2:"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeDateSecondsSince1970Strategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let result = try encoder.encode(model)


        let expects = "label1:1618721653.0\tlabel2:"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeDateMilliSecondsSince1970Strategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let result = try encoder.encode(model)


        let expects = "label1:1618721653000.0\tlabel2:"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeDateISO8601Strategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let result = try encoder.encode(model)

        let expects = "label1:2021-04-18T04:54:13Z\tlabel2:"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeDateGivenDateFormatterStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            formatter.dateFormat = "[dd/MMM/yyyy:HH:mm:ss Z]"
            return formatter
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let result = try encoder.encode(model)


        let expects = "label1:[18/Apr/2021:13:54:13 +0900]\tlabel2:"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeDateCustomStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
            formatter.dateFormat = "[dd/MMM/yyyy:HH:mm:ss Z]"
            return formatter
        }()

        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .custom({ (date) -> String in
            return dateFormatter.string(from: date)
        })
        let result = try encoder.encode(model)


        let expects = "label1:[18/Apr/2021:13:54:13 +0900]\tlabel2:"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeDateNginxTimeLocalStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Date
            let label2: Date?
        }

        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone.current
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()


        let model = Model(label1: date, label2: nil)

        let encoder = LTSVEncoder()
        encoder.dateEncodingStrategy = .nginxTimeLocal
        let result = try encoder.encode(model)

        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "Z"
            return formatter
        }()

        let expects = "label1:[18/Apr/2021:13:54:13 \(dateFormatter.string(from: date))]\tlabel2:"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeBoolDefaultStrategy() throws {
        struct Model: Codable, Equatable {
            let label1: Bool?
            let label2: Bool
            let label3: Bool
        }

        let model = Model(label1: nil, label2: true, label3: false)

        let encoder = LTSVEncoder()
        let result = try encoder.encode(model)

        let expects = "label1:\tlabel2:true\tlabel3:false"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeBoolCustomStrategy() throws {
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

        let expects = "label1:\tlabel2:good\tlabel3:bad"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeEnum() throws {

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
        let expects = "label1:200\tlabel2:404\tlabel3:200\tlabel4:404"

        XCTAssertEqual(result, expects)
    }

    func testLTSVEncodeStringBasedEnum() throws {

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
        let expects = "label1:200\tlabel2:404\tlabel3:200\tlabel4:404"

        XCTAssertEqual(result, expects)
    }

}








