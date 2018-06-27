//
//  Resource.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public protocol Resource: Decodable {
    static var endpointName: String { get }
}

// MARK: Unique Resource

// A resource type for which it can only exists one instante of
public protocol UniqueResource: Resource {
    static func get(completion: @escaping CompletionClosure<Self>)
}

extension UniqueResource {
    public static func get(completion: @escaping CompletionClosure<Self>) {
        SimpleMDM.shared.networkController.getUniqueResource(type: Self.self, completion: completion)
    }
}

// MARK: Identifiable Resource

// A resource for which multiple instance of can coexists, and is identifiable by an id
public protocol IdentifiableResource: Resource {
    associatedtype Identifier: LosslessStringConvertible & Comparable = Int

    static func get(id: Identifier, completion: @escaping CompletionClosure<Self>)
}

extension IdentifiableResource {
    public static func get(id: Identifier, completion: @escaping CompletionClosure<Self>) {
        SimpleMDM.shared.networkController.getResource(type: Self.self, withId: id, completion: completion)
    }
}

// MARK: Listable Resource

// A resource for which multiple instance of can coexists, and we can get a list of
public protocol ListableResource: IdentifiableResource {
    static func getAll(completion: @escaping CompletionClosure<[Self]>)
}

extension ListableResource {
    public static func getAll(completion: @escaping CompletionClosure<[Self]>) {
        SimpleMDM.shared.networkController.getAllResources(type: Self.self, completion: completion)
    }
}
