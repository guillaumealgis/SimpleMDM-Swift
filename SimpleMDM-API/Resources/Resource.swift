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

// MARK: Single Resource

public protocol SingleResource: Resource {
    static func get(completion: @escaping CompletionClosure<Self>)
}

extension SingleResource {
    public static func get(completion: @escaping CompletionClosure<Self>) {
        SimpleMDM.shared.networkController.getResource(ofType: Self.self, atEndpoint: endpointName, completion: completion)
    }
}

// MARK: Resource Cluster

public protocol ResourceCluster: Resource {
    static func get(id: Int, completion: @escaping CompletionClosure<Self>)
}

extension ResourceCluster {
    public static func get(id: Int, completion: @escaping CompletionClosure<Self>) {
        SimpleMDM.shared.networkController.getResource(ofType: Self.self, withId: id, atEndpoint: endpointName, completion: completion)
    }
}


