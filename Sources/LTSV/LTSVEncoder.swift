//
//  LTSVEncoder.swift
//  
//
//  Created by griffin-stewie on 2021/04/17.
//  
//

import Foundation

public final class LTSVEncoder {

    /// Contextual user-provided information for use during encoding.
    var userInfo: [CodingUserInfoKey : Any] = [:]

    /// Options set on the top-level encoder to pass down the encoding hierarchy.
    fileprivate struct _Options {
        let userInfo: [CodingUserInfoKey : Any]
    }

    /// The options set on the top-level encoder.
    fileprivate var options: _Options {
        return _Options(userInfo: userInfo)
    }

    // MARK: - Constructing a LTSV Encoder

    /// Initializes `self` with default strategies.
    public init() {}

    // MARK: - Encoding Values

    public func encode<T : Encodable>(_ value: T) throws -> String {
        let encoder = _LTSVEncoder(options: self.options)
        try value.encode(to: encoder)

        guard encoder.storage.count > 0 else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
        }

        return LTSV.covertToString(from: encoder.storage.containers)
    }
}

// MARK: - _LTSVEncoder

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

    // MARK: - Initialization

    fileprivate init(options: LTSVEncoder._Options, codingPath: [CodingKey] = []) {
        self.options = options
        self.storage = _LTSVEncodingStorage()
        self.codingPath = codingPath
    }

    // MARK: - Coding Path Operations

    /// Performs the given closure with the given key pushed onto the end of the current coding path.
    ///
    /// - parameter key: The key to push. May be nil for unkeyed containers.
    /// - parameter work: The work to perform with the key in the path.
    fileprivate func with<T>(pushedKey key: CodingKey, _ work: () throws -> T) rethrows -> T {
        self.codingPath.append(key)
        let ret: T = try work()
        self.codingPath.removeLast()
        return ret
    }

    // MARK: - Encoder Methods

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let topContainer: [String: String?] = [:]
        self.storage.push(container: topContainer)
        let container = _LTSVKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return _LTSVUnkeyedEncodingContainer(referencing: self, codingPath: self.codingPath)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("not implemented")
    }
}

// MARK: - Encoding Storage and Containers

fileprivate struct _LTSVEncodingStorage {
    // MARK: Properties

    /// The container stack.
    /// Elements
    private(set) fileprivate var containers: [[String: String?]] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    fileprivate init() {}

    // MARK: - Modifying the Stack

    fileprivate var count: Int {
        return self.containers.count
    }

    fileprivate mutating func push(container: [String: String?]) {
        self.containers.append(container)
    }

    fileprivate mutating func popContainer() -> [String: String?] {
        precondition(self.containers.count > 0, "Empty container stack.")
        return self.containers.popLast()!
    }
}

// MARK: - Encoding Containers

fileprivate struct _LTSVKeyedEncodingContainer<Key : CodingKey>  : KeyedEncodingContainerProtocol {
    /// A reference to the encoder we're writing to.
    private let encoder: _LTSVEncoder

    /// A reference to the container we're writing to.
    private var container: [String: String?]

    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: _LTSVEncoder, codingPath: [CodingKey], wrapping container: [String: String?]) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }


    mutating func encodeNil(forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: String?, forKey key: Self.Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer()
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
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

fileprivate struct _LTSVUnkeyedEncodingContainer : UnkeyedEncodingContainer {
    private let encoder: _LTSVEncoder

    private(set) public var codingPath: [CodingKey]

    var count: Int {
        return self.encoder.storage.count
    }

    fileprivate init(referencing encoder: _LTSVEncoder, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }

    mutating func encodeNil() throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Bool) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: String) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Double) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Float) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int8) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int16) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int32) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Int64) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: UInt) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: UInt8) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: UInt16) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: UInt32) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: UInt64) throws {
        fatalError("not implemented")
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        try value.encode(to: self.encoder)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("not implemented")
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("not implemented")
    }

    mutating func superEncoder() -> Encoder {
        fatalError("not implemented")
    }
}

// MARK: - Concrete Value Representations

extension _LTSVEncoder {
    /// Returns the given value boxed in a container appropriate for pushing onto the container stack.
//    fileprivate func box(_ value: Bool)   -> String { return NSNumber(value: value) }
    fileprivate func box(_ value: Int)    -> String { return String(value) }
    fileprivate func box(_ value: Int8)   -> String { return String(value) }
    fileprivate func box(_ value: Int16)  -> String { return String(value) }
    fileprivate func box(_ value: Int32)  -> String { return String(value) }
    fileprivate func box(_ value: Int64)  -> String { return String(value) }
    fileprivate func box(_ value: UInt)   -> String { return String(value) }
    fileprivate func box(_ value: UInt8)  -> String { return String(value) }
    fileprivate func box(_ value: UInt16) -> String { return String(value) }
    fileprivate func box(_ value: UInt32) -> String { return String(value) }
    fileprivate func box(_ value: UInt64) -> String { return String(value) }
    fileprivate func box(_ value: String) -> String { return value }
}
