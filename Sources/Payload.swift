//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
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
