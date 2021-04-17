//
//  LTSVEncoder.swift
//  
//
//  Created by griffin-stewie on 2021/04/17.
//  
//

import Foundation

public final class LTSVEncoder {

    public var userInfo: [CodingUserInfoKey : Any] = [:]

    fileprivate struct _Options {
        let userInfo: [CodingUserInfoKey : Any]
    }

    fileprivate var options: _Options {
        return _Options(userInfo: userInfo)
    }

    public func encode<T : Encodable>(_ value: T) throws -> String {
        let encoder = _LTSVEncoder(options: self.options)
        try value.encode(to: encoder)

        guard encoder.storage.count > 0 else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
        }

        return LTSV.covertToString(from: encoder.storage.containers)
    }
}

fileprivate class _LTSVEncoder: Encoder {
    // MARK: Properties

    var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey : Any] {
        return self.options.userInfo
    }

    /// The encoder's storage.
    fileprivate var storage: _LTSVEncodingStorage

    /// Options set on the top-level encoder.
    fileprivate let options: LTSVEncoder._Options

    fileprivate init(options: LTSVEncoder._Options, codingPath: [CodingKey] = []) {
        self.options = options
        self.storage = _LTSVEncodingStorage()
        self.codingPath = codingPath
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let topContainer: [String: String] = [:]
        self.storage.push(container: topContainer)
        let container = _LTSVKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("not implemented")
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("not implemented")
    }

}

fileprivate struct _LTSVKeyedEncodingContainer<Key : CodingKey>  : KeyedEncodingContainerProtocol {
    /// A reference to the encoder we're writing to.
    private let encoder: _LTSVEncoder

    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: _LTSVEncoder, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }


    mutating func encodeNil(forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        dict[key.stringValue] = value
        self.encoder.storage.push(container: dict)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        fatalError("not implemented")
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("not implemented")
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError("not implemented")
    }

    mutating func superEncoder() -> Encoder {
        fatalError("not implemented")
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        fatalError("not implemented")
    }

}

//// MARK: - Encoding Storage and Containers

fileprivate struct _LTSVEncodingStorage {
    // MARK: Properties

    /// The container stack.
    /// Elements
    private(set) fileprivate var containers: [[String: String]] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    fileprivate init() {}

    // MARK: - Modifying the Stack

    fileprivate var count: Int {
        return self.containers.count
    }

    fileprivate mutating func push(container: [String: String]) {
        self.containers.append(container)
    }

    fileprivate mutating func popContainer() -> [String: String] {
        precondition(self.containers.count > 0, "Empty container stack.")
        return self.containers.popLast()!
    }
}
