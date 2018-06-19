//
//  URLSession.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

internal protocol URLSessionProtocol {
    init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?)
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}
