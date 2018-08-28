//
//  URLSessionMock.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

@testable import SimpleMDM

enum URLSessionMockError: Error {
    case noMatchingRoute
}

struct Response {
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

let wildcardRoute = "*"

class URLSessionMock: URLSessionProtocol {
    let routes: [String: Response]

    init(routes: [String: Response]) {
        self.routes = routes
    }

    convenience init(data: Data? = Data(), responseCode: Int? = nil, responseMimeType: String? = "application/json") {
        let routes = [wildcardRoute: Response(data: data, code: responseCode, mimeType: responseMimeType)]
        self.init(routes: routes)
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let response = try! matchingResponseForRequest(request)

        let urlResponse: URLResponse?
        if let code = response.code {
            var headerFields: [String: String]? = nil
            if let mimeType = response.mimeType {
                headerFields = [
                    "Content-Type": mimeType
                ]
            }
            urlResponse = HTTPURLResponse(url: request.url!, statusCode: code, httpVersion: nil, headerFields: headerFields)
        }
        else {
            urlResponse = nil
        }

        if let delay = response.delay {
            // Simulate a delay in the request
            let deadline = DispatchTime.now() + delay
            DispatchQueue.global().asyncAfter(deadline: deadline, execute: {
                completionHandler(response.data, urlResponse, nil)
            })
        }
        else {
            completionHandler(response.data, urlResponse, nil)
        }

        return URLSessionDataTaskMock()
    }

    func matchingResponseForRequest(_ request: URLRequest) throws -> Response {
        for (path, response) in routes {
            if path == wildcardRoute || request.url?.path == path {
                return response
            }
        }
        throw URLSessionMockError.noMatchingRoute
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    override func cancel() {}
    override func suspend() {}
    override func resume() {}
}
