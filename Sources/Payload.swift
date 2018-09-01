//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

// MARK: Errors

struct ErrorPayload: Decodable {
    struct ErrorPayloadEntry: Decodable {
        let title: String
    }

    let errors: [ErrorPayloadEntry]
}

// MARK: Response data

protocol Payload: Decodable {
    associatedtype DataType: Decodable
    var data: DataType { get }
}

struct SinglePayload<R: Resource>: Payload {
    var data: R
}

struct ListPayload<R: Resource>: Payload {
    let data: [R]
    let hasMore: Bool
}
