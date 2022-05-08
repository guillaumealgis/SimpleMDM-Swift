//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

private typealias BaseSimpleMDMError = LocalizedError & Equatable

/// Internal errors of the SimpleMDM-Swift library.
///
/// These should be handled internally, and never be returned to an user of the library.
public enum InternalError: BaseSimpleMDMError {
    /// An internal error returned when an URL we're trying to construct is malformed.
    ///
    /// This should not happen. If you're getting this error, it means there's a bug in SimpleMDM-Swift.
    case malformedURL

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .malformedURL:
            return "The URL could not be constructed"
        }
    }
}

/// Errors occurring during the transport and decoding the HTTP response.
public enum NetworkError: BaseSimpleMDMError {
    /// The session returned a non-HTTP response.
    case noHTTPResponse

    /// The server responded with content of an unexpected MIME type.
    case unexpectedMimeType(String?)

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .noHTTPResponse:
            return "Did not receive a HTTP response"
        case let .unexpectedMimeType(mimeType):
            return "Received a response with an unexpected MIME type \"\(mimeType ?? "null")\""
        }
    }
}

/// Errors returned when misusing the SimpleMDM API.
public enum SimpleMDMError: BaseSimpleMDMError {
    /// The SimpleMDM API key was not set before sending a request.
    ///
    /// - SeeAlso: `SimpleMDM.apiKey`
    case apiKeyNotSet

    /// The SimpleMDM API key was rejected by the server.
    case apiKeyInvalid

    /// The server responded with an unexpected HTTP response code.
    case unknown(httpCode: Int)

    /// The server responded with an unexpected HTTP response code, and provided an error description.
    case generic(httpCode: Int, description: String)

    /// The requested resource does not exist.
    case doesNotExist

    /// The id of the received resource did not match the id of the requested resource.
    ///
    /// - Note: This should never happen. If you encountered this error, there's probably something wrong with the
    ///   SimpleMDM API.
    case unexpectedResourceId

    /// The request returned an empty list of resources, but the pagination API indicated than more resources are
    /// available.
    ///
    /// - Note: This should never happen. If you encountered this error, there's probably something wrong with the
    ///   SimpleMDM API.
    case doesNotExpectMoreResources

    /// The limit you provided when using the pagination API does not fit the bounds enforced by the server.
    case invalidLimit(Int)

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .apiKeyNotSet:
            return "The SimpleMDM API key was not set"
        case .apiKeyInvalid:
            return "The SimpleMDM server rejected the API key"
        case let .unknown(httpCode):
            return "Unknown API error (non-decodable payload, HTTP response code was \(httpCode)"
        case let .generic(httpCode, description):
            return "Unexpected API error (\(httpCode): \(description))"
        case .doesNotExist:
            return "The requested resource does not exist"
        case .unexpectedResourceId:
            return "A fetched resources had an unexpected id"
        case .doesNotExpectMoreResources:
            return "No resource was fetched, but the server advertised for more resources"
        case let .invalidLimit(limit):
            return "Limit \"\(limit)\" is invalid. Expected a number between \(PageLimit.min) and \(PageLimit.max)"
        }
    }
}
