//
//  URLSessionMock.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

@testable import SimpleMDM

class URLSessionMock: URLSessionProtocol {
    var data: Data?
    var responseCode: Int?
    var responseMimeType: String?
    var error: Error?

    required init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?) { }

    convenience init(data: Data? = Data(), responseCode: Int? = nil, responseMimeType: String? = "application/json", error:Error? = nil) {
        self.init(configuration: .default, delegate: nil, delegateQueue: nil)
        self.data = data
        self.responseCode = responseCode
        self.responseMimeType = responseMimeType
        self.error = error
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let response: URLResponse?
        if let code = responseCode {
            var headerFields: [String: String]? = nil
            if let mimeType = responseMimeType {
                headerFields = [
                    "Content-Type": mimeType
                ]
            }
            response = HTTPURLResponse(url: request.url!, statusCode: code, httpVersion: nil, headerFields: headerFields)
        }
        else {
            response = nil
        }
        completionHandler(data, response, error)
        return URLSessionDataTaskMock()
    }
}


}
