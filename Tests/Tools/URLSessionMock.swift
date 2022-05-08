//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

@testable import SimpleMDM

internal struct Response {
    let data: Data?
    let code: Int?
    let mimeType: String?
    let delay: TimeInterval?

    var nanosecondsDelay: UInt64? {
        guard let delay = delay else {
            return nil
        }

        return UInt64(delay)
    }

    init(data: Data?, code: Int? = 200, mimeType: String? = "application/json", delay: TimeInterval? = nil) {
        self.data = data
        self.code = code
        self.mimeType = mimeType
        self.delay = delay
    }
}

internal enum URLSessionMockError: Swift.Error {
    case noMatchingRoute(URL?)
    case noResponseCode
    case noRequestURL
    case couldNotCreateHTTPResponse
}

internal class URLSessionMock: URLSessionProtocol {
    static let wildcardRoute = "*"
    let routes: [String: Response]

    var handledRequests: [URLRequest] = []

    init(routes: [String: Response]) {
        self.routes = routes
    }

    convenience init(data: Data? = Data(), responseCode: Int? = nil, responseMimeType: String? = "application/json") {
        let routes = [URLSessionMock.wildcardRoute: Response(data: data, code: responseCode, mimeType: responseMimeType)]
        self.init(routes: routes)
    }

    func data(for request: URLRequest, delegate _: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw URLSessionMockError.noRequestURL
        }

        guard let response = matchingResponseForRequest(request) else {
            throw URLSessionMockError.noMatchingRoute(request.url)
        }

        if response.data == nil, response.code == nil {
            return (Data(), URLResponse())
        }

        guard let code = response.code else {
            throw URLSessionMockError.noResponseCode
        }

        var headerFields: [String: String]
        if let mimeType = response.mimeType {
            headerFields = [
                "Content-Type": mimeType
            ]
        } else {
            headerFields = [:]
        }
        guard let urlResponse = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: headerFields) else {
            throw URLSessionMockError.couldNotCreateHTTPResponse
        }

        if let delay = response.nanosecondsDelay {
            // Simulate a delay in the request
            try await Task.sleep(nanoseconds: delay)
        }

        handledRequests.append(request)

        return (response.data ?? Data(), urlResponse)
    }

    func matchingResponseForRequest(_ request: URLRequest) -> Response? {
        guard let url = request.url else {
            return nil
        }

        let requestURL: String
        if let query = url.query {
            requestURL = "\(url.path)?\(query)"
        } else {
            requestURL = url.path
        }

        for (route, response) in routes {
            if route == URLSessionMock.wildcardRoute || route == requestURL {
                return response
            }
        }
        return nil
    }
}
