//
//  LTSVEncoder.swift
//  
//
//  Created by griffin-stewie on 2021/04/17.
//  
//

import Foundation
import OrderedCollections

public final class LTSVEncoder {
    // MARK: Options

    /// The strategy to use for encoding `Date` values.
    public enum DateEncodingStrategy {
        /// Defer to `Date` for encoding. This is the default strategy.
        case deferredToDate

        /// Encode the `Date` as a UNIX timestamp from a number.
        case secondsSince1970

        /// Encode the `Date` as UNIX millisecond timestamp from a number.
        case millisecondsSince1970

        /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601

        /// Nginx $time_local This is the default strategy.
        case nginxTimeLocal

        /// Encode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)

        /// Encode the `Date` as a custom value decoded by the given closure.
        case custom((Date) throws -> String)
    }

    /// The strategy to use for encoding `Bool` values.
    public enum BoolEncodingStrategy {
        /// Encode the `Bool` using default initializer.
        case `default`

        /// Encode the `Bool` as a custom value encoded by the given closure.
        case custom((_ value: Bool) throws -> String)
    }

    /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
    public var dateEncodingStrategy: DateEncodingStrategy = .deferredToDate

    /// The strategy to use in encoding bools. Defaults to `.default`.
    public var boolEncodingStrategy: BoolEncodingStrategy = .default

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey : Any] = [:]

    /// Options set on the top-level encoder to pass down the encoding hierarchy.
    fileprivate struct _Options {
        let dateEncodingStrategy: DateEncodingStrategy
        let boolEncodingStrategy: BoolEncodingStrategy
        let userInfo: [CodingUserInfoKey : Any]
    }

    /// The options set on the top-level encoder.
    fileprivate var options: _Options {
        return _Options(
            dateEncodingStrategy: dateEncodingStrategy,
            boolEncodingStrategy: boolEncodingStrategy,
            userInfo: userInfo
        )
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

        return LTSV.covertToString(from: encoder.storage.containers as! [OrderedDictionary<String,String?>])
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

    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    fileprivate var canEncodeNewValue: Bool {
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        return self.storage.count == self.codingPath.count
    }

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
        let topContainer: OrderedDictionary<String,String?> = [:]
        self.storage.push(container: topContainer)
        let container = _LTSVKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return _LTSVUnkeyedEncodingContainer(referencing: self, codingPath: self.codingPath)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

// MARK: - Encoding Storage and Containers

fileprivate struct _LTSVEncodingStorage {
    // MARK: Properties

    /// The container stack.
    /// Elements
    private(set) fileprivate var containers: [Any] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    fileprivate init() {}

    // MARK: - Modifying the Stack

    fileprivate var count: Int {
        return self.containers.count
    }

    fileprivate mutating func push(container: Any) {
        self.containers.append(container)
    }

    fileprivate mutating func popContainer() -> Any {
        precondition(self.containers.count > 0, "Empty container stack.")
        return self.containers.popLast()!
    }
}

// MARK: - Encoding Containers

fileprivate struct _LTSVKeyedEncodingContainer<Key : CodingKey>  : KeyedEncodingContainerProtocol {
    /// A reference to the encoder we're writing to.
    private let encoder: _LTSVEncoder

    /// A reference to the container we're writing to.
    private var container: OrderedDictionary<String,String?>

    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: _LTSVEncoder, codingPath: [CodingKey], wrapping container: OrderedDictionary<String,String?>) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }


    mutating func encodeNil(forKey key: Key) throws {
        fatalError("not implemented")
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(try self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(try self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: String?, forKey key: Self.Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(self.encoder.box(value), forKey: key.stringValue)
    }

    mutating func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(self.encoder.box(wrapped), forKey: key.stringValue)
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }
        dict.updateValue(try self.encoder.box(value), forKey: key.stringValue)
    }

    func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
        var dict = self.encoder.storage.popContainer() as! OrderedDictionary<String,String?>
        defer { self.encoder.storage.push(container: dict) }

        guard let wrapped = value else {
            dict.updateValue(nil, forKey: key.stringValue)
            return
        }

        dict.updateValue(try self.encoder.box(wrapped), forKey: key.stringValue)
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

extension _LTSVEncoder : SingleValueEncodingContainer {
    // MARK: - SingleValueEncodingContainer Methods

    fileprivate func assertCanEncodeNewValue() {
        precondition(self.canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }

    public func encodeNil() throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: NSNull())
    }

    public func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: box(value))
    }

    public func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: box(value))
    }

    public func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: box(value))
    }

    public func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: box(value))
    }

    public func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: box(value))
    }

    public func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: box(value))
    }

    public func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: box(value))
    }

    public func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: box(value))
    }

    public func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: box(value))
    }

    public func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: box(value))
    }

    public func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        self.storage.push(container: box(value))
    }

    public func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: box(value))
    }

    public func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        try self.storage.push(container: box(value))
    }

    public func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: box(value))
    }

    public func encode<T : Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        fatalError("not implemented")
//        try self.storage.push(container: box(value))
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

    fileprivate func box(_ value: Double) -> String { return String(value) }

    fileprivate func box(_ value: Float) -> String { return String(value) }

    fileprivate func box(_ value: Bool) throws -> String {
        switch self.options.boolEncodingStrategy {
        case .default:
            return String(value)
        case .custom(let closure):
            return try closure(value)
        }
    }

    fileprivate func box(_ date: Date) throws -> String {
        switch self.options.dateEncodingStrategy {
        case .deferredToDate:
            // Must be called with a surrounding with(pushedKey:) call.
            try date.encode(to: self)
            return self.storage.popContainer() as! String

        case .secondsSince1970:
            return String(date.timeIntervalSince1970)

        case .millisecondsSince1970:
            return String(1000.0 * date.timeIntervalSince1970)

        case .iso8601:
            if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                return _iso8601Formatter.string(from: date)
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }

        case .nginxTimeLocal:
            return LTSV.dateFormatter.string(from: date)

        case .formatted(let formatter):
            return formatter.string(from: date)

        case .custom(let closure):
            return try closure(date)
        }
    }

    fileprivate func box<T : Encodable>(_ value: T) throws -> String {
        if T.self == Date.self {
            // Respect Date encoding strategy
            return try self.box((value as! Date))
        }

        // The value should request a container from the _LTSVEncoder.
        try value.encode(to: self)

        return self.storage.popContainer() as! String
    }
}

//===----------------------------------------------------------------------===//
// Shared ISO8601 Date Formatter
//===----------------------------------------------------------------------===//
// NOTE: This value is implicitly lazy and _must_ be lazy.
// We're compiled against the latest SDK (w/ ISO8601DateFormatter), but linked against whichever Foundation the user has.
// ISO8601DateFormatter might not exist, so we better not hit this code path on an older OS.
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
fileprivate var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()
