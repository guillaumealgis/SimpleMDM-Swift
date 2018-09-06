//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

// MARK: Error types

private typealias BaseSimpleMDMError = LocalizedError & Equatable

// Internal errors of the SimpleMDM-Swift library
public enum InternalError: BaseSimpleMDMError {
    case malformedURL
}

// Errors occuring during the transport and decoding the HTTP response
public enum NetworkError: BaseSimpleMDMError {
    case unknown
    case noHTTPResponse
    case unexpectedMimeType(String?)

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown network error"
        case .noHTTPResponse:
            return "Did not receive a HTTP response"
        case let .unexpectedMimeType(mimeType):
            return "Received a response with an unexpected MIME type \"\(mimeType ?? "null")\""
        }
    }
}

// SimpleMDM-level errors
// eg. The requested resource does not exist, the operation failed for some reason, etc.
public enum SimpleMDMError: BaseSimpleMDMError {
    case APIKeyNotSet
    case APIKeyInvalid
    case unknown(httpCode: Int)
    case generic(httpCode: Int, description: String)
    case doesNotExist
    case unexpectedResourceId
    case doesNotExpectMoreResources
    case invalidLimit(Int)

    public var errorDescription: String? {
        switch self {
        case .APIKeyNotSet:
            return "The SimpleMDM API key was not set"
        case .APIKeyInvalid:
            return "The SimpleMDM server rejected the API key"
        case let .unknown(httpCode):
            return "Unknown API error (empty payload, HTTP response code was \(httpCode)"
        case let .generic(httpCode, description):
            return "Unexpected API error (\(httpCode): \(description))"
        case .doesNotExist:
            return "The requested resource does not exist"
        case .unexpectedResourceId:
            return "A fetched resources had an unexpected id"
        case .doesNotExpectMoreResources:
            return "No resource was fetched, but the server advertised for more resources"
        case let .invalidLimit(limit):
            return "Limit \"\(limit)\" is invalid. Expected a number between \(CursorLimit.min) and \(CursorLimit.max)"
        }
    }
}
