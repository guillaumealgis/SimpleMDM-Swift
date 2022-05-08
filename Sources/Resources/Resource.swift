//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

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
    /// - Returns: The fetched resource.
    static func get() async throws -> Self
}

/// An extension of `UniqueResource` providing a default implementation for `get()`.
public extension UniqueResource {
    /// Fetch the resource from the server.
    ///
    /// - Returns: The fetched resource.
    static func get() async throws -> Self {
        let data = try await SimpleMDM.shared.networking.getDataForUniqueResource(ofType: Self.self)
        let resource = try SimpleMDM.shared.decoding.decodeContent(containedInPayloadOfType: SinglePayload<Self>.self, from: data)
        return resource
    }
}

// MARK: - Identifiable Resource

/// A protocol describing resource types of which multiple instances of can exists. These resources have an identifier
/// which is unique per instance of the resource.
public protocol IdentifiableResource: Resource, Identifiable, Hashable where ID: LosslessStringConvertible & Comparable & Decodable {}

public extension Equatable where Self: IdentifiableResource {
    /// Returns a Boolean value indicating whether two resources are equal.
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

public extension Hashable where Self: IdentifiableResource {
    /// Hashes id of this resource by feeding them into the given hasher.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// A protocol describing resource types that can be fetched independently, using their unique identifier
/// (these resources adopt the `IdentifiableResource` protocol).
public protocol GettableResource: IdentifiableResource {
    /// Get the instance of this resource with the identifier `id`.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the resource to get.
    ///
    /// - Returns: The fetched resource.
    static func get(id: ID) async throws -> Self
}

/// An extension of `GettableResource` providing a default implementation for `get(id:)`.
public extension GettableResource {
    /// Fetch the resource identified by `id` from the server.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the resource to get.
    ///
    /// - Returns: The fetched resource.
    static func get(id: ID) async throws -> Self {
        let data = try await SimpleMDM.shared.networking.getDataForResource(ofType: Self.self, withId: id)
        let resource = try SimpleMDM.shared.decoding.decodeContent(containedInPayloadOfType: SinglePayload<Self>.self, from: data)
        guard resource.id == id else {
            throw SimpleMDMError.unexpectedResourceId
        }
        return resource
    }
}

// MARK: - Listable Resource

/// A protocol describing resource types that we can get a list of.
public protocol ListableResource: GettableResource {}

/// A protocol describing resource types that we can get a list of and that can be fetched from the API independently
/// of another resource.
public protocol FetchableListableResource: ListableResource {
    /// Get a list of all resources of this type.
    ///
    /// - Returns: An async sequence of resources.
    static var all: AsyncResources<Self> { get }
}

/// An extension of `RootListableResource` providing a default implementation for `all`.
public extension FetchableListableResource {
    /// Fetch the list of all resources of this type.
    ///
    /// Because the SimpleMDM API enforces pagination when getting a list of resources, this method will fetch the
    /// resources page by page, and concatenate the results of each page. This means that if the total count of
    /// resources fetched is high (more than a hundred of resources), calling this method may end up making multiple
    /// HTTP requests to the SimpleMDM API.
    ///
    /// - Returns: An async sequence of resources.
    static var all: AsyncResources<Self> {
        AsyncResources<Self>()
    }
}

// MARK: - Searchable Resource

/// A protocol describing resource types for which we can get instances without knowing their identifier, by searching
/// for value in their properties.
/// Which properties are defined by the SimpleMDM implementation server-side. See the online SimpleMDM documentation.
///
/// - SeeAlso: `SearchCursor`.
public protocol SearchableResource: FetchableListableResource {
    static func search(_ searchString: String) async throws -> AsyncResources<Self>
}

public extension SearchableResource {
    static func search(_: String) async throws -> AsyncResources<Self> {
        AsyncResources<Self>()
    }
}
