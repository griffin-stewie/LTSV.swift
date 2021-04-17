//
//  File.swift
//  
//
//  Created by griffin-stewie on 2021/04/17.
//  
//

import Foundation

public final class LTSVDecoder {

    public var userInfo: [CodingUserInfoKey : Any] = [:]

    public func decode<T : Decodable>(_ type: T.Type, from string: String) throws -> T {
        let topLevel = LTSV.parseAny(from: string)
        let decoder = _LTSVDecoder(referencing: topLevel)
        return try T(from: decoder)
    }
}


private class _LTSVDecoder: Decoder {

    fileprivate var storage: _LTSVDecodingStorage

    public var codingPath: [CodingKey]

    public var userInfo: [CodingUserInfoKey : Any] = [:]

    fileprivate init(referencing container: Any, at codingPath: [CodingKey] = []) {
        self.storage = _LTSVDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
    }

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard let dict = self.storage.topContainer as? [String: String?] else {
            let description = "Expected to decode xxxxx"
            throw DecodingError.typeMismatch([String: String?].self, .init(codingPath: codingPath, debugDescription: description))
        }

        return KeyedDecodingContainer(LTSVKeyedDecodingContainer<Key>(referencing: self, wrapping: dict))
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let array = self.storage.topContainer as? [[String: String?]] else {
            let description = "Expected to decode xxxxx"
            throw DecodingError.typeMismatch([[String: String?]].self, .init(codingPath: codingPath, debugDescription: description))
        }

        return LTSVUnkeyedDecodingContainer(referencing: self, parsedArray: array)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError("not implemented")
    }
}

private extension _LTSVDecoder {
    func unbox<T : Decodable>(_ value: Any, as type: T.Type) throws -> T? {
        self.storage.push(container: value)
        let decoded = try T(from: self)
        self.storage.popContainer()

        return decoded
    }
}

private struct LTSVKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    var codingPath: [CodingKey]

    var allKeys: [Key] = []

    private let decoder: _LTSVDecoder

    var container: [String: String?]

    fileprivate init(referencing decoder: _LTSVDecoder, wrapping container: [String : String?]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
    }

    func contains(_ key: Key) -> Bool {
        return container[key.stringValue] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        fatalError("not implemented")
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        fatalError("not implemented")
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let v = self.container[key.stringValue]?.flatMap({$0}) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "TODO"))
        }

        return v
    }

    func decodeIfPresent(_ type: String.Type, forKey key: Self.Key) throws -> String? {
        guard let v = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "TODO"))
        }

        return v
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        fatalError("not implemented")
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        fatalError("not implemented")
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        fatalError("not implemented")
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        fatalError("not implemented")
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        fatalError("not implemented")
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        fatalError("not implemented")
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        fatalError("not implemented")
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        fatalError("not implemented")
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        fatalError("not implemented")
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        fatalError("not implemented")
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        fatalError("not implemented")
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        fatalError("not implemented")
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        fatalError("not implemented")
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("not implemented")
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError("not implemented")
    }

    func superDecoder() throws -> Decoder {
        fatalError("not implemented")
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError("not implemented")
    }
}

private struct LTSVUnkeyedDecodingContainer: UnkeyedDecodingContainer {

    private let decoder: _LTSVDecoder

    var codingPath: [CodingKey]

    public var count: Int? {
        return self.parsedArray.count
    }

    public var isAtEnd: Bool {
        return self.currentIndex >= self.count!
    }

    var currentIndex: Int

    var parsedArray: [[String: String?]]

    fileprivate init(referencing decoder: _LTSVDecoder, parsedArray: [[String: String?]]) {
        self.decoder = decoder
        self.parsedArray = parsedArray
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
    }

    mutating func decodeNil() throws -> Bool {
        fatalError("not implemented")
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        fatalError("not implemented")
    }

    mutating func decode(_ type: String.Type) throws -> String {
        fatalError("not implemented")
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        fatalError("not implemented")
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        fatalError("not implemented")
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        fatalError("not implemented")
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        fatalError("not implemented")
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        fatalError("not implemented")
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        fatalError("not implemented")
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        fatalError("not implemented")
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        fatalError("not implemented")
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        fatalError("not implemented")
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        fatalError("not implemented")
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        fatalError("not implemented")
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        fatalError("not implemented")
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Unkeyed container is at end."))
        }

        guard let decoded = try self.decoder.unbox(self.parsedArray[self.currentIndex], as: T.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "TODO TODO"))
        }

        self.currentIndex += 1
        return decoded
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("not implemented")
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("not implemented")
    }

    mutating func superDecoder() throws -> Decoder {
        fatalError("not implemented")
    }

}

fileprivate struct _LTSVDecodingStorage {

    private(set) fileprivate var containers: [Any] = []

    fileprivate init() {}

    // MARK: - Modifying the Stack

    fileprivate var count: Int {
        return self.containers.count
    }

    fileprivate var topContainer: Any {
        precondition(self.containers.count > 0, "Empty container stack.")
        return self.containers.last!
    }

    fileprivate mutating func push(container: Any) {
        self.containers.append(container)
    }

    fileprivate mutating func popContainer() {
        precondition(self.containers.count > 0, "Empty container stack.")
        self.containers.removeLast()
    }
}
