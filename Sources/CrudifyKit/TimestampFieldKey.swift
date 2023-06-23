//
//  TimestampFieldKey.swift
//  
//  Copyright (c) 2023 CrudifyKit Contributors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Fluent


/// Represents the keys for timestamp fields.
public enum TimestampFieldKey {
    
    case createdAt
    
    case updatedAt
    
}


/// This extension provides a computed property `fieldKey` for the `TimestampFieldKey` enum.
/// It maps each `TimestampFieldKey` case to a `FieldKey` with a specific string value.
public extension TimestampFieldKey {
    
    var fieldKey: FieldKey {
        switch self {
        case .createdAt:
            return .string("created_at")
        case .updatedAt:
            return .string("updated_at")
        }
    }
    
}


/// This extension adds a convenience initializer to the `FieldProperty` class.
/// The initializer takes a `timestampKey` of type `TimestampFieldKey` and creates a `FieldProperty` instance with the corresponding `fieldKey` from the `timestampKey`.
public extension FieldProperty {
    
    convenience init(timestamp timestampKey: TimestampFieldKey) {
        self.init(key: timestampKey.fieldKey)
    }
    
}


/// This extension adds a sort method to the `QueryBuilder` class.
/// The method allows sorting the query results based on a timestamp field specified by a `TimestampFieldKey`.
extension QueryBuilder {
    
    func sort(
        _ timestampFieldKey: TimestampFieldKey,
        _ direction: DatabaseQuery.Sort.Direction = .ascending
    ) -> Self {
        self.sort([timestampFieldKey.fieldKey], direction)
    }
    
}
