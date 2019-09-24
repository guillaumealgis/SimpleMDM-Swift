//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

@testable import SimpleMDM

internal struct Response {
    let data: Data?
    let code: Int?
    let mimeType: String?
    let delay: DispatchTimeInterval?

    init(data: Data?, code: Int? = 200, mimeType: String? = "application/json", delay: DispatchTimeInterval? = nil) {
        self.data = data
        self.code = code
        self.mimeType = mimeType
        self.delay = delay
    }
}

internal enum URLSessionMockError: Swift.Error {
    case noMatchingRoute(URL?)
}

internal class URLSessionMock: URLSessionProtocol {
    static let wildcardRoute = "*"
    let routes: [String: Response]

    init(routes: [String: Response]) {
        self.routes = routes
    }

    convenience init(data: Data? = Data(), responseCode: Int? = nil, responseMimeType: String? = "application/json") {
        let routes = [URLSessionMock.wildcardRoute: Response(data: data, code: responseCode, mimeType: responseMimeType)]
        self.init(routes: routes)
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        guard let response = matchingResponseForRequest(request) else {
            completionHandler(nil, nil, URLSessionMockError.noMatchingRoute(request.url))
            return URLSessionDataTaskMock()
        }

        let urlResponse: URLResponse?
        if let code = response.code, let url = request.url {
            var headerFields: [String: String]
            if let mimeType = response.mimeType {
                headerFields = [
                    "Content-Type": mimeType
                ]
            } else {
                headerFields = [:]
            }
            urlResponse = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: headerFields)
        } else {
            urlResponse = nil
        }

        if let delay = response.delay {
            // Simulate a delay in the request
            let deadline = DispatchTime.now() + delay
            DispatchQueue.global().asyncAfter(deadline: deadline) {
                completionHandler(response.data, urlResponse, nil)
            }
        } else {
            completionHandler(response.data, urlResponse, nil)
        }

        return URLSessionDataTaskMock()
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

internal class URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    func resume() {}
}
