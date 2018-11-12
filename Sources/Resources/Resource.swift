//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A completion clusure used to return a Result type asynchronously.
public typealias CompletionClosure<Value> = (Result<Value>) -> Void

/// A protocol adopted by all resources types of the library.
public protocol Resource: Decodable {
    /// The SimpleMDM API endpoint for this resources type.
    ///
    /// This is an implementation detail, and you shouldn't have to use this.
    static var endpointName: String { get }
}

// MARK: - Unique Resource

/// A protocol describing resource types of which only one instance exists. Such resources have not id and cannot be
/// listed.
public protocol UniqueResource: Resource {
    /// Get the unique instance of this resource.
    ///
    /// - Parameter completion: A completion handler called with the resource, or an error.
    static func get(completion: @escaping CompletionClosure<Self>)
}

/// An extension of `UniqueResource` providing a default implementation for `get(completion:)`.
public extension UniqueResource {
    /// Fetch the resource from the server.
    ///
    /// - Parameter completion: A completion handler called with the resource, or an error.
    static func get(completion: @escaping CompletionClosure<Self>) {
        get(SimpleMDM.shared.networking, completion: completion)
    }

    /// Actual implementation of the `get(completion:)` static method, with a injectable `Networking` parameter.
    internal static func get(_ networking: Networking, completion: @escaping CompletionClosure<Self>) {
        networking.getDataForUniqueResource(ofType: Self.self) { networkResult in
            let decoding = Decoding()
            let result = decoding.decodeNetworkingResult(networkResult, expectedPayloadType: SinglePayload<Self>.self)
            completion(result)
        }
    }
}

// MARK: - Identifiable Resource

/// A protocol describing resource types of which multiple instances of can exists. These resources have an identifier
/// which is unique per instance of the resource.
public protocol IdentifiableResource: Resource {
    /// The type of the resource identifier.
    associatedtype Identifier: LosslessStringConvertible & Comparable & Decodable

    /// The identifier of the resource.
    var id: Identifier { get }
}

/// A protocol describing resource types that can be fetched independently, using their unique identifier
/// (these resources adopt the `IdentifiableResource` protocol).
public protocol GettableResource: IdentifiableResource {
    /// Get the instance of this resource with the identifier `id`.
    ///
    /// - Parameter completion: A completion handler called with the resource, or an error.
    static func get(id: Identifier, completion: @escaping CompletionClosure<Self>)
}

/// An extension of `GettableResource` providing a default implementation for `get(id:completion:)`.
public extension GettableResource {
    /// Fetch the resource identified by `id` from the server.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the resource to get.
    ///   - completion: A completion handler called with the resource, or an error.
    static func get(id: Identifier, completion: @escaping CompletionClosure<Self>) {
        get(SimpleMDM.shared.networking, id: id, completion: completion)
    }

    /// Actual implementation of the `get(id:completion:)` method, with a injectable `Networking` parameter.
    internal static func get(_ networking: Networking, id: Identifier, completion: @escaping CompletionClosure<Self>) {
        networking.getDataForResource(ofType: Self.self, withId: id) { networkResult in
            let decoding = Decoding()
            let result = decoding.decodeNetworkingResult(networkResult, expectedPayloadType: SinglePayload<Self>.self)
            if case let .success(resource) = result, resource.id != id {
                completion(.failure(SimpleMDMError.unexpectedResourceId))
                return
            } else {
                completion(result)
            }
        }
    }
}

// MARK: - Listable Resource

/// A protocol describing resource types that we can get a list of.
public protocol ListableResource: GettableResource {
    /// Get a list of all resources of this type.
    ///
    /// - Parameter completion: A completion handler called with a list of resources, or an error.
    static func getAll(completion: @escaping CompletionClosure<[Self]>)
}

/// An extension of `ListableResource` providing a default implementation for `getAll(completion:)`.
public extension ListableResource {
    /// Fetch the list of all resources of this type.
    ///
    /// Because the SimpleMDM API enforces pagination when getting a list of resources, this method will fetch the
    /// resources page by page, and concatenate the results of each page. This means that if the total count of
    /// resources fetched is high (more than a hundred of resources), calling this method may end up making multiple
    /// HTTP requests to the SimpleMDM API.
    ///
    /// - Important: Prefer using the `Cursor` class over this convenience method when fetching large lists of
    ///   resources (see Discussion).
    ///
    /// - Parameter completion: A completion handler called with a list of resources, or an error.
    static func getAll(completion: @escaping CompletionClosure<[Self]>) {
        getAll(SimpleMDM.shared.networking, completion: completion)
    }

    /// Actual implementation of the `getAll(completion:)` method, with a injectable `Networking` parameter.
    internal static func getAll(_ networking: Networking, completion: @escaping CompletionClosure<[Self]>) {
        let accumulator = [Self]()
        let cursor = Cursor<Self>()
        getNext(networking, accumulator: accumulator, cursor: cursor, completion: completion)
    }

    /// Recursive method fetching all resources of this type page by page.
    ///
    /// - Parameters:
    ///   - networking: An injectable object used to perform the network requests.
    ///   - accumulator: A list of all the resources fetched up to this point.
    ///   - cursor: A cursor used to fetch the resources.
    ///   - completion: A completion handler called with the content of `accumulator` once we arrive to the end of the
    ///     list, or an error if one occurs.
    private static func getNext(_ networking: Networking, accumulator: [Self], cursor: Cursor<Self>, completion: @escaping CompletionClosure<[Self]>) {
        if !cursor.hasMore {
            completion(.success(accumulator))
            return
        }

        cursor.next(networking, CursorLimit.max.rawValue) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(resources):
                let accumulator = accumulator + resources
                getNext(networking, accumulator: accumulator, cursor: cursor, completion: completion)
            }
        }
    }
}

// MARK: - Searchable Resource

/// A protocol describing resource types for which we can get instances without knowing their identifier, by searching
/// for value in their properties.
/// Which properties are defined by the SimpleMDM implementation server-side. See the online SimpleMDM documentation.
///
/// - SeeAlso: `SearchCursor`.
public protocol SearchableResource: ListableResource {}
