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

internal final class TableEncoder: Encoder {

    private var container: Any?
    private var keyedPrimaryKeyEncodableTableContainer: KeyedPrimaryKeyEncodableTableContainer?

    private let recyclableHandleStatement: RecyclableHandleStatement

    internal typealias HashedKey = [Int: Int] // hash value -> index
    private let hashedKeys: HashedKey

    internal var primaryKeyHash: Int?
    internal var isPrimaryKeyEncoded = true

    internal init(_ codingTableKeys: ContiguousArray<CodingTableKeyBase>,
                  on recyclableHandleStatement: RecyclableHandleStatement) {
        var hashedKeys: HashedKey = [:]
        for (index, key) in codingTableKeys.enumerated() {
            hashedKeys[key.stringValue.hashValue] = index + 1
        }
        self.hashedKeys = hashedKeys
        self.recyclableHandleStatement = recyclableHandleStatement
    }

    internal init(_ hashedKeys: HashedKey, on recyclableHandleStatement: RecyclableHandleStatement) {
        self.hashedKeys = hashedKeys
        self.recyclableHandleStatement = recyclableHandleStatement
    }

    internal func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        if container == nil {
            let keyedContainer = KeyedEncodingTableContainer<Key>(with: hashedKeys,
                                                                  on: recyclableHandleStatement.raw)
            keyedPrimaryKeyEncodableTableContainer = keyedContainer
            container = KeyedEncodingContainer(keyedContainer)
        }
        if isPrimaryKeyEncoded {
            keyedPrimaryKeyEncodableTableContainer?.primaryKeyHash = nil
        } else {
            keyedPrimaryKeyEncodableTableContainer?.primaryKeyHash = primaryKeyHash
        }
        return container as! KeyedEncodingContainer<Key>
    }

    private class KeyedPrimaryKeyEncodableTableContainer {
        final var primaryKeyHash: Int?
    }

    private final class KeyedEncodingTableContainer<CodingKeys: CodingKey>
        : KeyedPrimaryKeyEncodableTableContainer, KeyedEncodingContainerProtocol {
        internal typealias Key = CodingKeys

        private let handleStatement: HandleStatement
        private let hashedKeys: HashedKey

        init(with hashedKeys: HashedKey,
             on handleStatement: HandleStatement) {
            self.hashedKeys = hashedKeys
            self.handleStatement = handleStatement
            super.init()
        }

        private func bindIndex(by hashValue: Int) -> Int? {
            return hashedKeys[hashValue]
        }

        internal func bindPrimaryKeyOrReturnIndex(forKey key: Key) -> Int? {
            let hashValue = key.stringValue.hashValue
            guard let index = bindIndex(by: hashValue) else {
                return nil
            }
            guard hashValue == primaryKeyHash else {
                return index
            }
            handleStatement.bind(nil, toIndex: index)
            return nil
        }

        internal func encodeNil(forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(nil, toIndex: index)
        }

        internal func encode(_ value: Int, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value.toInt64(), toIndex: index)
        }

        internal func encode(_ value: Bool, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value.toInt32(), toIndex: index)
        }

        internal func encode(_ value: Float, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value.toDouble(), toIndex: index)
        }

        internal func encode(_ value: Double, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value, toIndex: index)
        }

        internal func encode(_ value: String, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value, toIndex: index)
        }

        internal func encode<Object>(_ value: Object, forKey key: Key) throws where Object: Encodable {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            //`key` must conform to ColumnEncodable protocol.
            let encodableColumnValue = value as! ColumnEncodableBase
            handleStatement.bind(encodableColumnValue.archivedFundamentalValue(), toIndex: index)
        }

        internal func encode(_ value: Int8, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value.toInt32(), toIndex: index)
        }

        internal func encode(_ value: Int16, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value.toInt32(), toIndex: index)
        }

        internal func encode(_ value: Int32, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value, toIndex: index)
        }

        internal func encode(_ value: Int64, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value, toIndex: index)
        }

        internal func encode(_ value: UInt, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value.toInt64(), toIndex: index)
        }

        internal func encode(_ value: UInt8, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value.toInt32(), toIndex: index)
        }

        internal func encode(_ value: UInt16, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value.toInt32(), toIndex: index)
        }

        internal func encode(_ value: UInt32, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value.toInt32(), toIndex: index)
        }

        internal func encode(_ value: UInt64, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            handleStatement.bind(value.toInt64(), toIndex: index)
        }

        internal func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue.toInt32(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue.toInt64(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue.toInt32(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue.toInt32(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue, toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue, toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue.toInt64(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue.toInt32(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue.toInt32(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue.toInt32(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue.toInt64(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue.toDouble(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue, toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent(_ value: String?, forKey key: Key) throws {
            guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                return
            }
            if let wrappedValue = value {
                handleStatement.bind(wrappedValue, toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal func encodeIfPresent<Object>(_ value: Object?,
                                              forKey key: Key) throws
            where Object: Encodable {
                guard let index = bindPrimaryKeyOrReturnIndex(forKey: key) else {
                    return
                }
            if value != nil {
                //`key` must conform to ColumnEncodable protocol.
                let encodableColumnValue = value! as! ColumnEncodableBase
                handleStatement.bind(encodableColumnValue.archivedFundamentalValue(), toIndex: index)
            } else {
                handleStatement.bind(nil, toIndex: index)
            }
        }

        internal var codingPath: [CodingKey] {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }

        internal func superEncoder() -> Swift.Encoder {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }

        internal func superEncoder(forKey key: Key) -> Swift.Encoder {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }

        internal func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type,
                                                 forKey key: Key) -> KeyedEncodingContainer<NestedKey>
            where NestedKey: CodingKey {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }

        internal func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
        }
    }

    internal var codingPath: [CodingKey] {
        fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
    }

    internal var userInfo: [CodingUserInfoKey: Any] {
        fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
    }

    internal func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
    }

    internal func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("It should not be called. If you think it's a bug, please report an issue to us.")
    }
}
