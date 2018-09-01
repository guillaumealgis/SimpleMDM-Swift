//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
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
        case let .unexpectedMimeType(mimeType):
            return "Received a response with an unexpected MIME type \"\(mimeType ?? "null")\""
        }
    }
}

// SimpleMDM-level errors
// eg. The requested resource does not exist, the operation failed for some reason, etc.
public enum APIError: SimpleMDMError {
    case unknown(httpCode: Int)
    case generic(httpCode: Int, description: String)
    case doesNotExist
    case unexpectedResourceId

    public var errorDescription: String? {
        switch self {
        case let .unknown(httpCode):
            return "Unknown API error (empty payload, HTTP response code was \(httpCode)"
        case let .generic(httpCode, description):
            return "Unexpected API error (\(httpCode): \(description))"
        case .doesNotExist:
            return "The requested resource does not exist"
        case .unexpectedResourceId:
            return "A fetched resources had an unexpected id"
        }
    }
}
