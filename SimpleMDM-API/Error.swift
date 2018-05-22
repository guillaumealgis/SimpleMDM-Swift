//
//  Error.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

// MARK: Error types

// Errors related to the SimpleMDM API key
public enum APIKeyError: LocalizedError {
    case notSet
    case invalid

    public var errorDescription: String? {
        switch self {
        case .notSet:
            return "The SimpleMDM API key was not set"
        case .invalid:
            return "The SimpleMDM server rejected the API key"
        }
    }
}

// Errors occuring during the transport and decoding the HTTP response
enum NetworkError: LocalizedError {
    case unknown
    case noHTTPResponse
    case unexpectedMimeType(String?)

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown network error"
        case .noHTTPResponse:
            return "Did not receive a HTTP response"
        case .unexpectedMimeType(let mimeType):
            return "Received a response with an unexpected MIME type \"\(mimeType ?? "null")\""
        }
    }
}

// SimpleMDM-level errors
// eg. The requested resource does not exist, the operation failed for some reason, etc.
enum APIError : LocalizedError {
    case generic(code: Int, description: String)
    case doesNotExist
}

// MARK: Decoding the SimpleMDM error payload

internal struct ErrorPayload: Decodable {
    let title: String
}
