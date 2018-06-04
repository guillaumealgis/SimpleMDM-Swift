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
    var code: Int?
    var error: Error?

    required init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?) { }

    convenience init(data: Data?, code: Int?, error:Error?) {
        self.init(configuration: .default, delegate: nil, delegateQueue: nil)
        self.data = data
        self.code = code
        self.error = error
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let response: URLResponse?
        if let code = code {
            response = HTTPURLResponse(url: request.url!, statusCode: code, httpVersion: nil, headerFields: nil)
        }
        else {
            response = nil
        }
        completionHandler(data, response, error)
        return URLSessionDataTask()
    }


}
