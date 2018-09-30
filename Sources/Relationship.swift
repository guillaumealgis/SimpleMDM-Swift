//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

// Regroup all types defining a relation to one or more resources
private protocol RelatedToResource {}

// Regroup all types for which the relation is defined by a decodable entry in the "relationships" part in the JSON
private protocol Relationship: RelatedToResource, Decodable {}

public protocol RemoteCollection {
    associatedtype Element: IdentifiableResource

    func get(_ id: Element.Identifier, completion: @escaping CompletionClosure<Element>)
    func getAll(completion: @escaping CompletionClosure<[Element]>)
}

// MARK: Relation

private struct Relation<T: IdentifiableResource>: Decodable {
    let type: String
    let id: T.Identifier
}

// MARK: RelatedToOne

public struct RelatedToOne<T: GettableResource>: Relationship {
    private enum CodingKeys: String, CodingKey {
        case data
    }

    private let relation: Relation<T>

    public var relatedId: T.Identifier {
        return relation.id
    }

    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)
        relation = try payload.decode(Relation.self, forKey: .data)
    }

    public func get(completion: @escaping CompletionClosure<T>) {
        T.get(id: relation.id, completion: completion)
    }
}

// MARK: RelatedToMany

public struct RelatedToMany<Element: GettableResource>: Relationship, RemoteCollection {
    private enum CodingKeys: String, CodingKey {
        case data
    }

    private let relations: [Relation<Element>]

    public var relatedIds: [Element.Identifier] {
        return relations.map { $0.id }
    }

    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)
        relations = try payload.decode([Relation].self, forKey: .data)
    }

    public func get(at index: Int, completion: @escaping CompletionClosure<Element>) {
        Element.get(id: relations[index].id, completion: completion)
    }

    public func get(_ id: Element.Identifier, completion: @escaping CompletionClosure<Element>) {
        Element.get(id: id, completion: completion)
    }

    public func getAll(completion: @escaping CompletionClosure<[Element]>) {
        var resources = [Element]()
        var error: Error?

        let semaphore = DispatchSemaphore(value: 1)
        let group = DispatchGroup()

        for i in 0 ..< relations.count {
            group.enter()
            get(at: i) { result in
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
                    let firstResourcePosition = self.relatedIds.index(of: $0.id) ?? 0
                    let secondResourcePosition = self.relatedIds.index(of: $1.id) ?? 0
                    return firstResourcePosition < secondResourcePosition
                }
                result = .success(resources)
            }
            completion(result)
        }
    }
}

// MARK: RelatedToManyNested

public struct RelatedToManyNested<Parent: IdentifiableResource, Element: IdentifiableResource>: RelatedToResource, RemoteCollection {
    private let parentId: Parent.Identifier

    init(parentId: Parent.Identifier) {
        self.parentId = parentId
    }

    public func get(_ id: Element.Identifier, completion: @escaping (Result<Element>) -> Void) {
        getAll { result in
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

    public func getAll(completion: @escaping CompletionClosure<[Element]>) {
        SimpleMDM.shared.networking.getDataForNestedResources(ofType: Element.self, inParent: Parent.self, withId: parentId) { networkResult in
            let decoding = Decoding()
            let result = decoding.decodeNetworkingResult(networkResult, expectedPayloadType: ListPayload<Element>.self)
            completion(result)
        }
    }
}
