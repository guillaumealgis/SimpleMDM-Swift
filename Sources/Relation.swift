//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

// MARK: Relation

private struct Relation<T: IdentifiableResource>: Decodable {
    let type: String
    let id: T.Identifier
}

// MARK: RelatedToOne

private protocol RelatedToResource: Decodable {}

public struct RelatedToOne<T: IdentifiableResource>: RelatedToResource {
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

public struct RelatedToMany<T: IdentifiableResource>: RelatedToResource {
    private enum CodingKeys: String, CodingKey {
        case data
    }

    private let relations: [Relation<T>]

    public var relatedIds: [T.Identifier] {
        return relations.map { $0.id }
    }

    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)
        relations = try payload.decode([Relation].self, forKey: .data)
    }

    public func get(at index: Int, completion: @escaping CompletionClosure<T>) {
        T.get(id: relations[index].id, completion: completion)
    }

    public func getAll(completion: @escaping CompletionClosure<[T]>) {
        var resources = [T]()
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
            let result: Result<[T]>
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
