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
    struct ErrorPayloadEntry: Decodable {
        let title: String
    }

    let errors: [ErrorPayloadEntry]
}

// MARK: Response data

internal protocol Payload: Decodable {
    associatedtype DataType: Decodable
    var data: DataType { get }
}

internal struct SinglePayload<R: Resource>: Payload {
    var data: R
}

internal struct ListPayload<R: Resource>: Payload {
    let data: [R]
}
