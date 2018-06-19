//
//  Error.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

// MARK: Error types

private typealias SimpleMDMError = LocalizedError & Equatable

// Errors related to the SimpleMDM API key
public enum APIKeyError: SimpleMDMError {
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
public enum NetworkError: SimpleMDMError {
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
public enum APIError : SimpleMDMError {
    case unknown(code: Int)
    case generic(code: Int, description: String)
    case doesNotExist

    public var errorDescription: String? {
        switch self {
        case let .unknown(code):
            return "Unknown API error (empty payload, HTTP response code was \(code)"
        case let .generic(code, description):
            return "Unexpected API error (\(code): \(description))"
        case .doesNotExist:
            return "The requested resource does not exist"
        }
    }
}
