//
//  Copyright 2021 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

import PromiseKit

/// A PromiseKit default implementation for objects adopting the `UniqueResource` protocol.
public extension UniqueResource {
    /// Get the unique instance of this resource.
    ///
    /// - Returns: A promise that fulfills with the unique instance of this resource.
    static func get() -> Promise<Self> {
        return get(SimpleMDM.shared.networking)
    }

    /// Actual implementation of the `get()` static method, with a injectable `Networking` parameter.
    internal static func get(_ networking: Networking) -> Promise<Self> {
        return Promise { get(networking, completion: $0.resolve) }
    }
}

/// A PromiseKit default implementation for objects adopting the `GettableResource` protocol.
public extension GettableResource {
    /// Fetch the resource from the server.
    ///
    /// - Returns: A promise that fulfills with the resource.
    static func get(id: ID) -> Promise<Self> {
        return get(SimpleMDM.shared.networking, id: id)
    }

    /// Actual implementation of the `get(id:)` static method, with a injectable `Networking` parameter.
    internal static func get(_ networking: Networking, id: ID) -> Promise<Self> {
        return Promise { get(networking, id: id, completion: $0.resolve) }
    }
}

/// A PromiseKit default implementation for objects adopting the `ListableResource` protocol.
public extension ListableResource {
    /// Get a list of all resources of this type.
    ///
    /// - Returns: A promise that fulfills with a list of the fetched resources.
    static func getAll() -> Promise<[Self]> {
        return getAll(SimpleMDM.shared.networking)
    }

    /// Actual implementation of the `getAll()` static method, with a injectable `Networking` parameter.
    internal static func getAll(_ networking: Networking) -> Promise<[Self]> {
        return Promise { getAll(networking, completion: $0.resolve) }
    }
}

/// A PromiseKit default implementation for objects adopting the `RelatedToOne` protocol.
public extension RelatedToOne {
    /// Fetch the related resource from the server.
    ///
    /// - Returns: A promise that fulfills with the resource.
    func get() -> Promise<T> {
        return get(SimpleMDM.shared.networking)
    }

    /// Actual implementation of the `get()` static method, with a injectable `Networking` parameter.
    internal func get(_ networking: Networking) -> Promise<T> {
        return Promise { get(networking, completion: $0.resolve) }
    }
}

/// A PromiseKit default implementation for objects adopting the `RelatedToMany` protocol.
public extension RelatedToMany {
    /// Fetch the related resource at `index` in the collection from the server.
    ///
    /// - Parameter index: The index of the resource to fetch in the collection.
    /// - Returns: A promise that fulfills with the resource.
    func get(at index: Int) -> Promise<Element> {
        return get(SimpleMDM.shared.networking, at: index)
    }

    /// Fetch the related resource with the identifier `id` in the collection from the server.
    ///
    /// - Parameter index: The index of the resource to fetch in the collection.
    /// - Returns: A promise that fulfills with the resource.
    func get(id: Element.ID) -> Promise<Element> {
        return get(SimpleMDM.shared.networking, id: id)
    }

    /// Fetch all related resources from the server.
    ///
    /// The resources in the resulting collection a guaranteed to be in the same order as their id in `relatedIds`.
    ///
    /// - Warning: Because the SimpleMDM API offers no way to fetch multiple resources by id at once, this method will
    ///   fetch resources one by one, and then merge the result in an array. This means that calling this method will
    ///   make as many HTTP requests to the SimpleMDM API as there is resources in the relation.
    ///
    /// - Returns: A promise that fulfills with a list of the fetched resources.
    func getAll() -> Promise<[Element]> {
        return getAll(SimpleMDM.shared.networking)
    }

    /// Actual implementation of the `get(at:)` static method, with a injectable `Networking` parameter.
    internal func get(_ networking: Networking, at index: Int) -> Promise<Element> {
        return Promise { get(networking, at: index, completion: $0.resolve) }
    }

    /// Actual implementation of the `get(id:)` static method, with a injectable `Networking` parameter.
    internal func get(_ networking: Networking, id: Element.ID) -> Promise<Element> {
        return Promise { get(networking, id: id, completion: $0.resolve) }
    }

    /// Actual implementation of the `getAll()` static method, with a injectable `Networking` parameter.
    internal func getAll(_ networking: Networking) -> Promise<[Element]> {
        return Promise { getAll(networking, completion: $0.resolve) }
    }
}

/// A PromiseKit default implementation for objects adopting the `RelatedToManyNested` protocol.
public extension RelatedToManyNested {
    /// Fetch the related resource with the identifier `id` in the collection from the server.
    ///
    /// - Parameter index: The index of the resource to fetch in the collection.
    /// - Returns: A promise that fulfills with the resource.
    func get(id: Element.ID) -> Promise<Element> {
        return get(SimpleMDM.shared.networking, id: id)
    }

    /// Fetch all related resources from the server.
    ///
    /// The resources in the resulting collection a guaranteed to be in the same order as their id in `relatedIds`.
    ///
    /// - Returns: A promise that fulfills with a list of the fetched resources.
    func getAll() -> Promise<[Element]> {
        return getAll(SimpleMDM.shared.networking)
    }

    /// Actual implementation of the `get(id:)` static method, with a injectable `Networking` parameter.
    internal func get(_ networking: Networking, id: Element.ID) -> Promise<Element> {
        return Promise { get(networking, id: id, completion: $0.resolve) }
    }

    /// Actual implementation of the `getAll()` static method, with a injectable `Networking` parameter.
    internal func getAll(_ networking: Networking) -> Promise<[Element]> {
        return Promise { getAll(networking, completion: $0.resolve) }
    }
}

/// A PromiseKit default implementation for objects adopting the `Cursor` protocol.
public extension Cursor {
    /// Fetch the next page of resources.
    ///
    /// - Parameter The number of resources to fetch in this page. If not provided a default number of resources will
    ///     be returned by the SimpleMDM API.
    /// - Returns: A promise that fulfills with a list of resource.
    func next(_ limit: Int? = nil) -> Promise<[T]> {
        return next(SimpleMDM.shared.networking, limit)
    }

    /// Actual implementation of the `next(_:)` static method, with a injectable `Networking` parameter.
    internal func next(_ networking: Networking, _ limit: Int? = nil) -> Promise<[T]> {
        return Promise { next(networking, limit, completion: $0.resolve) }
    }
}
