//
//  Copyright 2020 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

// MARK: - URLSessionProtocol

/// Internal protocol used to make the networking part of the library easier to inject.
internal protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        let task: URLSessionDataTask = dataTask(with: request, completionHandler: completionHandler)
        return task
    }
}

// MARK: - URLSessionDataTaskProtocol

/// Internal protocol used to make the networking part of the library easier to inject.
internal protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
