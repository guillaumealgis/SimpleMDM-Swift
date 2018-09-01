//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

@testable import SimpleMDM

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
        guard let response = matchingResponseForRequest(request) else {
            fatalError("Found no matching route for URL \"\(request.url?.absoluteString ?? "<empty URL>")\"")
        }

        let urlResponse: URLResponse?
        if let code = response.code {
            var headerFields: [String: String]?
            if let mimeType = response.mimeType {
                headerFields = [
                    "Content-Type": mimeType
                ]
            }
            urlResponse = HTTPURLResponse(url: request.url!, statusCode: code, httpVersion: nil, headerFields: headerFields)
        } else {
            urlResponse = nil
        }

        if let delay = response.delay {
            // Simulate a delay in the request
            let deadline = DispatchTime.now() + delay
            DispatchQueue.global().asyncAfter(deadline: deadline, execute: {
                completionHandler(response.data, urlResponse, nil)
            })
        } else {
            completionHandler(response.data, urlResponse, nil)
        }

        return URLSessionDataTaskMock()
    }

    func matchingResponseForRequest(_ request: URLRequest) -> Response? {
        for (path, response) in routes {
            if path == wildcardRoute || request.url?.path == path {
                return response
            }
        }
        return nil
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    override func cancel() {}
    override func suspend() {}
    override func resume() {}
}
