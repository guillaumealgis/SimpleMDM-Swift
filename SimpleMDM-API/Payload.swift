//
//  Payload.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 06/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

// MARK: Errors

internal struct ErrorPayload: Decodable {
    let errors: [ErrorPayloadEntry]
}

internal struct ErrorPayloadEntry: Decodable {
    let title: String
}

// MARK: Response data

internal protocol Payload: Decodable {
    associatedtype ResourceType: Decodable
    associatedtype DataType: Decodable

    var data: DataType { get }

    func extractResource() -> ResourceType
}

internal struct SimplePayload<R: Resource>: Payload {
    typealias ResourceType = R
    let data: ResourcePayload<R>

    func extractResource() -> R {
        return data.attributes
    }
}

internal struct ListPayload<R: Resource>: Payload {
    typealias ResourceType = [R]
    let data: [ResourcePayload<R>]

    func extractResource() -> [R] {
        return data.map({ $0.attributes })
    }
}

internal struct ResourcePayload<R: Resource>: Decodable {
    let type: String
    let attributes: R
}
