//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

public typealias CompletionClosure<Value> = (Result<Value>) -> Void

public protocol AutoDecodable: Decodable {}

public protocol Resource: AutoDecodable {
    static var endpointName: String { get }
}

// MARK: Unique Resource

// A resource type for which it can only exists one instante of
public protocol UniqueResource: Resource {
    static func get(completion: @escaping CompletionClosure<Self>)
}

public extension UniqueResource {
    static func get(completion: @escaping CompletionClosure<Self>) {
        SimpleMDM.shared.networking.getDataForUniqueResource(ofType: Self.self) { networkResult in
            let decoding = Decoding()
            let result = decoding.decodeNetworkingResult(networkResult, expectedPayloadType: SinglePayload<Self>.self)
            completion(result)
        }
    }
}

// MARK: Identifiable Resource

// A resource for which multiple instance of can coexists, and is identifiable by an id
public protocol IdentifiableResource: Resource {
    associatedtype Identifier: LosslessStringConvertible & Comparable & Decodable

    var id: Identifier { get }

    static func get(id: Identifier, completion: @escaping CompletionClosure<Self>)
}

public extension IdentifiableResource {
    static func get(id: Identifier, completion: @escaping CompletionClosure<Self>) {
        SimpleMDM.shared.networking.getDataForResource(ofType: Self.self, withId: id) { networkResult in
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

// MARK: Listable Resource

// A resource for which multiple instance of can coexists, and we can get a list of
public protocol ListableResource: IdentifiableResource {
    static func getAll(completion: @escaping CompletionClosure<[Self]>)
}

public extension ListableResource {
    static func getAll(completion: @escaping CompletionClosure<[Self]>) {
        let accumulator = [Self]()
        let cursor = Cursor<Self>()
        getNext(accumulator: accumulator, cursor: cursor, completion: completion)
    }

    private static func getNext(accumulator: [Self], cursor: Cursor<Self>, completion: @escaping CompletionClosure<[Self]>) {
        if !cursor.hasMore {
            completion(.success(accumulator))
            return
        }

        cursor.next(CursorLimit.max.rawValue) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(resources):
                let accumulator = accumulator + resources
                getNext(accumulator: accumulator, cursor: cursor, completion: completion)
            }
        }
    }
}
