//
//  Resource.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
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

extension UniqueResource {
    public static func get(completion: @escaping CompletionClosure<Self>) {
        SimpleMDM.shared.networkingService.getDataForAllResources(ofType: Self.self) { networkResult in
            let result = processNetworkingResult(networkResult, expectedPayloadType: SinglePayload<Self>.self)
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

extension IdentifiableResource {
    public static func get(id: Identifier, completion: @escaping CompletionClosure<Self>) {
        SimpleMDM.shared.networkingService.getDataForSingleResource(ofType: Self.self, withId: id) { networkResult in
            let result = processNetworkingResult(networkResult, expectedPayloadType: SinglePayload<Self>.self)
            if case let .success(resource) = result, resource.id != id {
                completion(.failure(APIError.unexpectedResourceId))
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

extension ListableResource {
    public static func getAll(completion: @escaping CompletionClosure<[Self]>) {
        SimpleMDM.shared.networkingService.getDataForAllResources(ofType: Self.self) { networkResult in
            let result = processNetworkingResult(networkResult, expectedPayloadType: ListPayload<Self>.self)
            completion(result)
        }
    }
}

// MARK: Processing API response

private func processNetworkingResult<P: Payload>(_ result: NetworkingResult, expectedPayloadType _: P.Type) -> Result<P.DataType> {
    let decodingService = SimpleMDM.shared.decodingService
    switch result {
    case let .success(data):
        do {
            return .success(try decodingService.decodePayload(ofType: P.self, from: data))
        } catch {
            return .failure(error)
        }
    case let .decodableDataFailure(httpCode, data):
        return .failure(decodingService.decodeError(from: data, httpCode: httpCode))
    case let .failure(error):
        return .failure(error)
    }
}
