/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

internal final class TableDecoder: Decoder {

    private let recyclableHandleStatement: RecyclableHandleStatement

    internal typealias HashedKey = [Int: Int] // hash value -> index
    private let hashedKeys: HashedKey

    private var container: Any?

    internal init(_ codingTableKeys: ContiguousArray<CodingTableKeyBase>,
                  on recyclableHandleStatement: RecyclableHandleStatement) {
        var hashedKeys: HashedKey = [:]
        for (index, key) in codingTableKeys.enumerated() {
            hashedKeys[key.stringValue.hashValue] = index
        }
        self.hashedKeys = hashedKeys
        self.recyclableHandleStatement = recyclableHandleStatement
    }

    internal init(_ hashedKeys: HashedKey, on recyclableHandleStatement: RecyclableHandleStatement) {
        self.hashedKeys = hashedKeys
        self.recyclableHandleStatement = recyclableHandleStatement
    }

    internal func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        if container == nil {
            container = KeyedDecodingContainer(KeyedDecodingTableContainer<Key>(with: hashedKeys,
                                                                                on: recyclableHandleStatement.raw))
        }
        // It should not be failed. If you think it's a bug, please report an issue to us.
        return container as! KeyedDecodingContainer<Key>
    }

    private final class KeyedDecodingTableContainer<CodingKeys: CodingKey> : KeyedDecodingContainerProtocol {
        internal typealias Key = CodingKeys

        private let handleStatement: HandleStatement

        private let hashedKeys: HashedKey

        internal init(with hashedKeys: HashedKey, on handleStatement: HandleStatement) {
            self.handleStatement = handleStatement
            self.hashedKeys = hashedKeys
        }

        private func columnIndex(by key: Key) -> Int {
            let index = hashedKeys[key.stringValue.hashValue]
            assert(index != nil, "If [\(key)] would not be decoded, please make it optional.")
            return index!
        }

        private func columnIndexIfPresent(by key: Key) -> Int? {
            return hashedKeys[key.stringValue.hashValue]
        }

        internal func contains(_ key: Key) -> Bool {
            return true
        }

        //Decode
        internal func decodeNil(forKey key: Key) throws -> Bool {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toBool()
        }

        internal func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toBool()
        }

        internal func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Int64.self).toInt()
        }

        internal func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toInt8()
        }

        internal func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toInt16()
        }

        internal func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index)
        }

        internal func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index)
        }

        internal func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Int64.self).toUInt()
        }

        internal func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toUInt8()
        }

        internal func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toUInt16()
        }

        internal func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toUInt32()
        }

        internal func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Int64.self).toUInt64()
        }

        internal func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index, of: Double.self).toFloat()
        }

        internal func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index)
        }

        internal func decode(_ type: String.Type, forKey key: Key) throws -> String {
            let index: Int = columnIndex(by: key)
            return handleStatement.columnValue(atIndex: index)
        }

        internal func decode<Object>(_ type: Object.Type, forKey key: Key) throws -> Object where Object: Decodable {
            let index: Int = columnIndex(by: key)
            //`key` must conform to ColumnDecodable protocol.
            let decodableType = Object.self as! ColumnDecodableBase.Type
            var decoded: ColumnDecodableBase? = nil
            switch decodableType.columnType {
            case .integer32:
                decoded = decodableType.init(with: handleStatement.columnValue(atIndex: index, of: Int32.self))
            case .integer64:
                decoded = decodableType.init(with: handleStatement.columnValue(atIndex: index, of: Int64.self))
            case .float:
                decoded = decodableType.init(with: handleStatement.columnValue(atIndex: index, of: Double.self))
            case .text:
                decoded = decodableType.init(with: handleStatement.columnValue(atIndex: index, of: String.self))
            case .BLOB:
                decoded = decodableType.init(with: handleStatement.columnValue(atIndex: index, of: Data.self))
            default:
                fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
            }
            guard let wrappedDecoded = decoded else {
                throw Error.reportCore(tag: handleStatement.tag,
                                       path: handleStatement.path,
                                       operation: .encode,
                                       code: .misuse,
                                       message: "If [\(key)] would be decoded as nil, please make it optional.")
            }
            //It should not be failed. If you think it's a bug, please report an issue to us.
            return wrappedDecoded as! Object
        }

        //Decode if present
        internal func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                return nil
            }
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toBool()
        }

        internal func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index, of: Int64.self).toInt()
        }

        internal func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toInt8()
        }

        internal func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toInt16()
        }

        internal func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index)
        }

        internal func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index)
        }

        internal func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index, of: Int64.self).toUInt()
        }

        internal func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toUInt8()
        }

        internal func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toUInt16()
        }

        internal func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index, of: Int32.self).toUInt32()
        }

        internal func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index, of: Int64.self).toUInt64()
        }

        internal func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index, of: Double.self).toFloat()
        }

        internal func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index)
        }

        internal func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            return handleStatement.columnValue(atIndex: index)
        }

        internal func decodeIfPresent<Object>(_ type: Object.Type, forKey key: Key)
            throws -> Object? where Object: Decodable {
            guard let index = columnIndexIfPresent(by: key), handleStatement.columnType(atIndex: index) != .null else {
                    return nil
            }
            //`key` must conform to ColumnDecodable protocol.
            let decodableType = Object.self as! ColumnDecodableBase.Type
            var decoded: ColumnDecodableBase? = nil
            switch decodableType.columnType {
            case .integer32:
                decoded = decodableType.init(with: handleStatement.columnValue(atIndex: index, of: Int32.self))
            case .integer64:
                decoded = decodableType.init(with: handleStatement.columnValue(atIndex: index, of: Int64.self))
            case .float:
                decoded = decodableType.init(with: handleStatement.columnValue(atIndex: index, of: Double.self))
            case .text:
                decoded = decodableType.init(with: handleStatement.columnValue(atIndex: index, of: String.self))
            case .BLOB:
                decoded = decodableType.init(with: handleStatement.columnValue(atIndex: index, of: Data.self))
            default:
                fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
            }
            guard let wrappedDecoded = decoded else {
                return nil
            }
            //It should not be failed. If you think it's a bug, please report an issue to us.
            return (wrappedDecoded as! Object)
        }

        internal var codingPath: [CodingKey] {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }

        internal var allKeys: [Key] {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }

        internal func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type,
                                                 forKey key: Key) throws -> KeyedDecodingContainer<NestedKey>
            where NestedKey: CodingKey {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }

        internal func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }

        internal func superDecoder() throws -> Swift.Decoder {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }

        internal func superDecoder(forKey key: Key) throws -> Swift.Decoder {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }
    }

    internal var codingPath: [CodingKey] {
        fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
    }

    internal var userInfo: [CodingUserInfoKey: Any] {
        fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
    }

    internal func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
    }

    internal func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
    }
}
