//
//  Resource.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public protocol GenericResource: Decodable {
    static var endpointName: String { get }
}

// MARK: Unique Resource

// A resource type for which it can only exists one instante of
public protocol UniqueResource: GenericResource {
    static func get(completion: @escaping CompletionClosure<Self>)
}

extension UniqueResource {
    public static func get(completion: @escaping CompletionClosure<Self>) {
        SimpleMDM.shared.networkController.getUniqueResource(type: Self.self, completion: completion)
    }
}

// MARK: Resource Cluster

// A classic resource type, multiple instante of it can coexist
public protocol Resource: GenericResource {
    static func get(id: Int, completion: @escaping CompletionClosure<Self>)
    static func getAll(completion: @escaping CompletionClosure<[Self]>)
}

extension Resource {
    public static func get(id: Int, completion: @escaping CompletionClosure<Self>) {
        SimpleMDM.shared.networkController.getResource(type: Self.self, withId: id, completion: completion)
    }

    public static func getAll(completion: @escaping CompletionClosure<[Self]>) {
        SimpleMDM.shared.networkController.getAllResources(type: Self.self, completion: completion)
    }
}


