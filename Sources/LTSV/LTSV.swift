import Foundation

public struct LTSV {
    static func parse(from string: String) -> [[String: String]] {
        var parsedLines: [[String: String]] = []
        string.enumerateLines { row, _ in
            parsedLines.append(parse(row: row))
        }
        return parsedLines
    }

    static func parse(row string: String) -> [String: String] {
        return string.components(separatedBy: "\t").reduce(into: Dictionary<String,String>()) { dict, compo in
            let array = compo.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            guard array.count == 2 else {
                fatalError() // TODO: throw error
            }
            let key = String(array[0])
            let value = String(array[1])
            dict[key] = value
        }
    }
}

internal extension LTSV {
    static func parseAny(from string: String) -> Any {
        let parsedLines: [[String: String]] = self.parse(from: string)
        if parsedLines.count == 1 {
            return parsedLines[0]
        }

        return parsedLines
    }
}
