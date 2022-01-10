//
//  LTSV.swift
//
//
//  Created by griffin-stewie on 2021/04/17.
//
//

import Foundation
import OrderedCollections

public struct LTSV {
    public static func parse(from string: String) -> [OrderedDictionary<String,String?>] {
        var parsedLines: [OrderedDictionary<String,String?>] = []
        string.enumerateLines { row, _ in
            parsedLines.append(parse(row: row))
        }
        return parsedLines
    }

    public static func parse(row string: String) -> OrderedDictionary<String,String?> {
        let result = string.components(separatedBy: "\t").reduce(into: OrderedDictionary<String,String?>()) { dict, compo in
            let array = compo.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            guard array.count >= 1  else {
                fatalError() // TODO: throw error
            }
            let key = String(array[0])

            if array.endIndex == 1 {
                // Use `updateValue` to keep the existence of the key in the dictionary.
                dict.updateValue(nil, forKey: key)
            } else {
                dict.updateValue(String(array[1]), forKey: key)
            }
        }

        return result
    }
}

internal extension LTSV {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "[dd/MMM/yyyy:HH:mm:ss Z]"
        return formatter
    }()
}

internal extension LTSV {
    static func parseAny(from string: String) -> Any {
        let parsedLines: [OrderedDictionary<String,String?>] = self.parse(from: string)
        if parsedLines.count == 1 {
            return parsedLines[0]
        }

        return parsedLines
    }

    static func covertToString(from container: [OrderedDictionary<String,String?>]) -> String {
        var output = ""

        for dict in container {
            for (key, value) in dict {
                print(key, value ?? "", separator: ":", terminator: "\t", to: &output)
            }
            output.removeLast()
            print("", to: &output)
        }

        return output.trimmingCharacters(in: .newlines)
    }
}
