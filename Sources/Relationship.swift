//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A type defining a relation to one or more resources.
private protocol RelatedToResource {}

/// A type for which the relation is defined by a decodable entry in the "relationships" part of the reponse payload.
private protocol Relationship: RelatedToResource, Decodable {}

/// A type defining methods to fetch all collection of objects from a remote server.
public protocol RemoteCollection {
    /// The type of the elements contained in the collection.
    associatedtype Element: IdentifiableResource

    /// Fetch one of the remote resources from the collection by id.
    ///
    /// If no object in the collection has the identifier `id`, a `SimpleMDMError.unexpectedResourceId` error is
    /// returned in the completion block instead of a resource.
    ///
    /// - Parameters:
    ///   - id: The identifier of the resource to fetch.
    ///   - completion: A completion handler called with the fetched resource, or an error.
    func get(id: Element.Identifier, completion: @escaping CompletionClosure<Element>)

    /// Fetch all remote resources in the collection.
    ///
    /// - Parameter completion: A completion handler called with an array of the fetched resources, or an error.
    func getAll(completion: @escaping CompletionClosure<[Element]>)
}

// MARK: - Relation

/// A type used to represent a relation to another resource.
///
/// - SeeAlso:
///   - `RelatedToOne`
///   - `RelatedToMany`
private struct Relation<T: IdentifiableResource>: Decodable {
    /// The type name of the related object
    let type: String
    /// The identifier name of the related object
    let id: T.Identifier
}

// MARK: - RelatedToOne

/// A relation to another resource.
///
/// The related resouce can be retrieved from the server using `get(completion:)`.
public struct RelatedToOne<T: GettableResource>: Relationship {
    private enum CodingKeys: String, CodingKey {
        case data
    }

    /// The underlying relation informations used to fetch the remote resource.
    private let relation: Relation<T>

    /// The identifier of the related resource.
    ///
    /// Accessing this property does not make a network request, so it can be used in some cases to optimize
    /// your application if you don't need the full related resource content.
    public var relatedId: T.Identifier {
        return relation.id
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)
        relation = try payload.decode(Relation.self, forKey: .data)
    }

    /// Fetch the related resource from the server.
    ///
    /// - Parameter completion: A completion handler called with the fetched resource, or an error.
    public func get(completion: @escaping CompletionClosure<T>) {
        get(SimpleMDM.shared.networking, completion: completion)
    }

    /// Actual implementation of the `get(completion:)` method, with a injectable `Networking` parameter.
    internal func get(_ networking: Networking, completion: @escaping CompletionClosure<T>) {
        T.get(networking, id: relation.id, completion: completion)
    }
}

// MARK: - RelatedToMany

/// A relation to a group of remote resources.
///
/// The related resouces can be retrieved from the server either by id, by index, or by fetching the entire collection.
public struct RelatedToMany<Element: GettableResource>: Relationship, RemoteCollection {
    private enum CodingKeys: String, CodingKey {
        case data
    }

    /// The underlying relations informations used to fetch the remote resources.
    private let relations: [Relation<Element>]

    /// The identifiers of the related resources.
    ///
    /// Accessing this property does not make a network request, so it can be used in some cases to optimize
    /// your application if you don't need the full related resources content.
    public var relatedIds: [Element.Identifier] {
        return relations.map { $0.id }
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)
        relations = try payload.decode([Relation].self, forKey: .data)
    }

    /// Fetch the related resource at `index` in the collection from the server.
    ///
    /// - Parameters:
    ///   - index: The index of the resource to fetch in the collection.
    ///   - completion: A completion handler called with the fetched resource, or an error.
    public func get(at index: Int, completion: @escaping CompletionClosure<Element>) {
        get(SimpleMDM.shared.networking, at: index, completion: completion)
    }

    /// Actual implementation of the `get(at:completion:)` method, with a injectable `Networking` parameter.
    internal func get(_ networking: Networking, at index: Int, completion: @escaping CompletionClosure<Element>) {
        Element.get(networking, id: relations[index].id, completion: completion)
    }

    /// Fetch the related resource with the identifier `id` in the collection from the server.
    ///
    /// - Parameters:
    ///   - index: The index of the resource to fetch in the collection.
    ///   - completion: A completion handler called with the fetched resource, or an error.
    public func get(id: Element.Identifier, completion: @escaping CompletionClosure<Element>) {
        get(SimpleMDM.shared.networking, id: id, completion: completion)
    }

    /// Actual implementation of the `get(id:completion:)` method, with a injectable `Networking` parameter.
    internal func get(_ networking: Networking, id: Element.Identifier, completion: @escaping CompletionClosure<Element>) {
        Element.get(networking, id: id, completion: completion)
    }

    /// Fetch all related resources from the server.
    ///
    /// The resources in the resulting collection a guaranteed to be in the same order as their id in `relatedIds`.
    ///
    /// - Warning: Because the SimpleMDM API offers no way to fetch multiple resources by id at once, this method will
    ///   fetch resources one by one, and then merge the result in an array. This means that calling this method will
    ///   make as many HTTP requests to the SimpleMDM API as there is resources in the relation.
    ///
    /// - Parameter completion: A completion handler called with the fetched resources, or an error.
    public func getAll(completion: @escaping CompletionClosure<[Element]>) {
        getAll(SimpleMDM.shared.networking, completion: completion)
    }

    /// Actual implementation of the `getAll(completion:)` method, with a injectable `Networking` parameter.
    internal func getAll(_ networking: Networking, completion: @escaping CompletionClosure<[Element]>) {
        var resources = [Element]()
        var error: Error?

        let semaphore = DispatchSemaphore(value: 1)
        let group = DispatchGroup()

        for i in 0 ..< relations.count {
            group.enter()
            get(networking, at: i) { result in
                semaphore.wait()
                switch result {
                case let .success(resource):
                    resources.append(resource)
                case let .failure(err):
                    error = err
                }
                semaphore.signal()
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            let result: Result<[Element]>
            if let error = error {
                result = .failure(error)
            } else {
                // Because the resources will not necessarily arrive in the right order, we need to sort them
                // according to their id position in relatedIds
                resources.sort {
                    // We know here that the fetched id will be in the `relatedIds` collection, otherwise a
                    // SimpleMDMError.unexpectedResourceId would have been raised earlier.
                    // swiftlint:disable force_unwrapping
                    let firstResourcePosition = self.relatedIds.firstIndex(of: $0.id)!
                    let secondResourcePosition = self.relatedIds.firstIndex(of: $1.id)!
                    // swiftlint:enable force_unwrapping
                    return firstResourcePosition < secondResourcePosition
                }
                result = .success(resources)
            }
            completion(result)
        }
    }
}

// MARK: - RelatedToManyNested

/// A type defining an attribute of a resource having a "link" to its parent resource.
internal protocol NestedResourceAttribute {
    /// The type of the parent resource.
    associatedtype Parent: IdentifiableResource

    /// The identifier of the parent resource.
    var parentId: Parent.Identifier { get }

    /// Initialize the attribute with the identifier of the parent resource.
    ///
    /// - Parameter parentId: The identifier of the parent resource.
    init(parentId: Parent.Identifier)
}

/// A special kind of relation to a group of remote resources, where the related resources are "children" resources of
/// another resource.
///
/// This is mostly a detail implementation of the SimpleMDM API. You can use this type of relation as if it was a
/// `RelatedToMany` relation for the most part. The only differences being that we do not know the related resources
/// ids ahead of time, so this object does not exposes a `relatedIds` property, nor a `get(at:completion:)` method.
///
/// - SeeAlso: `RelatedToMany`
public struct RelatedToManyNested<Parent: IdentifiableResource, Element: IdentifiableResource>: RelatedToResource, NestedResourceAttribute, RemoteCollection {
    internal let parentId: Parent.Identifier

    internal init(parentId: Parent.Identifier) {
        self.parentId = parentId
    }

    /// Fetch the related resource with the identifier `id` in the collection from the server.
    ///
    /// - Parameters:
    ///   - index: The index of the resource to fetch in the collection.
    ///   - completion: A completion handler called with the fetched resource, or an error.
    public func get(id: Element.Identifier, completion: @escaping (Result<Element>) -> Void) {
        get(SimpleMDM.shared.networking, id: id, completion: completion)
    }

    /// Actual implementation of the `get(id:completion:)` method, with a injectable `Networking` parameter.
    internal func get(_ networking: Networking, id: Element.Identifier, completion: @escaping (Result<Element>) -> Void) {
        getAll(networking) { result in
            switch result {
            case let .success(nestedResources):
                guard let resource = nestedResources.first(where: { $0.id == id }) else {
                    return completion(.failure(SimpleMDMError.doesNotExist))
                }
                completion(.success(resource))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /// Fetch all related resources from the server.
    ///
    /// The resources in the resulting collection a guaranteed to be in the same order as their id in `relatedIds`.
    ///
    /// - Parameter completion: A completion handler called with the fetched resources, or an error.
    public func getAll(completion: @escaping CompletionClosure<[Element]>) {
        getAll(SimpleMDM.shared.networking, completion: completion)
    }

    /// Actual implementation of the `getAll(completion:)` method, with a injectable `Networking` parameter.
    internal func getAll(_ networking: Networking, completion: @escaping CompletionClosure<[Element]>) {
        networking.getDataForNestedResources(ofType: Element.self, inParent: Parent.self, withId: parentId) { networkResult in
            let decoding = Decoding()
            let result = decoding.decodeNetworkingResult(networkResult, expectedPayloadType: ListPayload<Element>.self)
            completion(result)
        }
    }
}
