//
//  CrudifyRouteCollection.swift
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
import Vapor


/// A protocol for defining a route collection with CRUD operations.
public protocol CrudifyRouteCollection: RouteCollection {
    
    /// The type of the model that is being crudified.
    associatedtype CrudifyModel: Model & Content where CrudifyModel.IDValue: LosslessStringConvertible
    
    /// The searchable fields for the model.
    var searchableFields: [String] { get }
    
    /// Creates routes using the provided `RoutesBuilder`.
    ///
    /// - Parameters:
    ///   - routes: The `RoutesBuilder` used to create routes.
    /// - Returns: A `RoutesBuilder` instance with the created routes.
    func createRoutesBuilder(from routes: RoutesBuilder) -> RoutesBuilder
    
    /// Handles the index route request and returns a response asynchronously.
    ///
    /// - Parameters:
    ///   - req: The `Request` object.
    /// - Returns: A `Response` object representing the result of the index operation.
    /// - Throws: An error if the index operation encounters an issue.
    func index(req: Request) async throws -> Response
    
    /// Handles the search route request and returns a response asynchronously.
    ///
    /// - Parameters:
    ///   - req: The `Request` object.
    /// - Returns: A `Response` object representing the result of the search operation.
    /// - Throws: An error if the search operation encounters an issue.
    func search(req: Request) async throws -> Response
    
    /// Handles the item route request and returns a response asynchronously.
    ///
    /// - Parameters:
    ///   - req: The `Request` object.
    /// - Returns: A `Response` object representing the result of the item operation.
    /// - Throws: An error if the item operation encounters an issue.
    func item(req: Request) async throws -> Response
    
    /// Handles the create route request and returns a response asynchronously.
    ///
    /// - Parameters:
    ///   - req: The `Request` object.
    /// - Returns: A `Response` object representing the result of the create operation.
    /// - Throws: An error if the create operation encounters an issue.
    func create(req: Request) async throws -> Response
    
    /// Handles the update route request and returns a response asynchronously.
    ///
    /// - Parameters:
    ///   - req: The `Request` object.
    /// - Returns: A `Response` object representing the result of the update operation.
    /// - Throws: An error if the update operation encounters an issue.
    func update(req: Request) async throws -> Response
    
    /// Handles the delete route request and returns a response asynchronously.
    ///
    /// - Parameters:
    ///   - req: The `Request` object.
    /// - Returns: A `Response` object representing the result of the delete operation.
    /// - Throws: An error if the delete operation encounters an issue.
    func delete(req: Request) async throws -> Response
        
}



public extension CrudifyRouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        self.createRoutesBuilder(from: routes)
            .setup(self)
    }
    
    func index(req: Request) async throws -> Response {
        var query = CrudifyModel.query(on: req.db)
        if let _ = CrudifyModel.self as? HasTimestamp.Type {
            query = query.sort(.createdAt, .descending)
        }
        return try await query.paginate(for: req).encodeResponse(for: req)
    }
    
    func search(req: Request) async throws -> Response {
        var query = CrudifyModel.query(on: req.db)
        self.searchableFields.forEach { fieldName in
            if let searchForInt: Int? = req.query[fieldName] {
                query = query.filter(.string(fieldName), .equal, searchForInt)
            } else if let searchForString: String? = req.query[fieldName] {
                query = query.filter(.string(fieldName), .contains(inverse: false, .anywhere), searchForString)
            }
        }
        if let _ = CrudifyModel.self as? HasTimestamp.Type {
            query = query.sort(.createdAt, .descending)
        }
        return try await query.paginate(for: req).encodeResponse(for: req)
    }
    
    func item(req: Request) async throws -> Response {
        guard let item = try await CrudifyModel.find(req.parameters.get("id"), on: req.db) else {
            return Response(status: .notFound)
        }
        return try await item.encodeResponse(for: req)
    }
    
    func create(req: Request) async throws -> Response {
        let item = try req.content.decode(CrudifyModel.self)
        if var timestampedItem = item as? HasTimestamp {
            timestampedItem.createdAt = Date()
        }
        try await item.save(on: req.db)
        return try await item.encodeResponse(for: req)
    }
    
    func update(req: Request) async throws -> Response {
        guard let dbItem = try await CrudifyModel.find(req.parameters.get("id"), on: req.db) else {
            return Response(status: .notFound)
        }
        let updateItem = try req.content.decode(CrudifyModel.self)
        updateItem._$idExists = true
        updateItem.id = dbItem.id
        if var timestampedUpdateItem = updateItem as? HasTimestamp, let timestampedDbItem = dbItem as? HasTimestamp {
            timestampedUpdateItem.createdAt = timestampedDbItem.createdAt
            timestampedUpdateItem.updatedAt = Date()
        }
        try await updateItem.save(on: req.db)
        return try await updateItem.encodeResponse(for: req)
    }
    
    func delete(req: Request) async throws -> Response {
        guard let item = try await CrudifyModel.find(req.parameters.get("id"), on: req.db) else {
            return Response(status: .notFound)
        }
        try await item.delete(on: req.db)
        return Response(status: .noContent)
    }
    
}
