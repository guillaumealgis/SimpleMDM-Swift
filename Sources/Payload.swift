//
//  Copyright 2020 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

// MARK: - Errors

/// A struct describing the content of error response from the API.
internal struct ErrorPayload: Decodable {
    struct ErrorPayloadEntry: Decodable {
        let title: String
    }

    let errors: [ErrorPayloadEntry]
}

// MARK: - Response data

/// A struct describing the content of success response from the API.
internal protocol Payload: Decodable {
    associatedtype DataType: Decodable

    var data: DataType { get }
}

/// A struct describing the content of success response from the API when fetching an unique resource.
internal struct SinglePayload<R: Resource>: Payload {
    var data: R
}

/// A struct describing the content of success response from the API when fetching a list of resources.
internal struct ListPayload<R: Resource>: Payload {
    let data: [R]
}

/// A struct describing the content of success response from the API when fetching a list of resources with pagination
/// enabled.
internal struct PaginatedListPayload<R: Resource>: Payload {
    let data: [R]
    let hasMore: Bool
}
