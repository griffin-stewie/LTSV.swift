import XCTest
@testable import LTSV

final class DateFormatterTests: XCTestCase {
    func testDateToNginxTimeLocal() {
        let date: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

        let formatter = LTSV.dateFormatter

        let result = formatter.string(from: date)
        let expects = "[18/Apr/2021:13:54:13 +0900]"
        XCTAssertEqual(result, expects)
    }

    func testDateFromNginxTimeLocal() {
        let expects: Date = {
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(abbreviation: "ja-JP")
            let dCompo = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 4, day: 18, hour: 13, minute: 54, second: 13)
            let date = dCompo.date!
            return date
        }()

        let formatter = LTSV.dateFormatter
        let result = formatter.date(from: "[18/Apr/2021:13:54:13 +0900]")

        XCTAssertEqual(result, expects)
    }

    static var allTests = [
        ("testDateToNginxTimeLocal", testDateToNginxTimeLocal),
        ("testDateFromNginxTimeLocal", testDateFromNginxTimeLocal),
    ]
}

