//
//  RoutesBuilder+Crudify.swift
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


public extension RoutesBuilder {
    
    /// Sets up the routes for a `CrudifyRouteCollection`.
    ///
    /// - Parameters:
    ///   - routes: The `CrudifyRouteCollection` to set up.
    func setup(_ routes: any CrudifyRouteCollection) {
        self.get(use: routes.index)
        self.post(use: routes.create)
        self.group(":id") { subBuilder in
            subBuilder.get(use: routes.item)
            subBuilder.put(use: routes.update)
            subBuilder.patch(use: routes.update)
            subBuilder.delete(use: routes.delete)
        }
        self.group("search") { subBuilder in
            subBuilder.get(use: routes.search)
        }
    }
    
}
