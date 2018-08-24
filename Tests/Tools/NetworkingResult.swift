//
//  NetworkingResult.swift
//  SimpleMDM
//
//  Created by Guillaume Algis on 24/08/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

@testable import SimpleMDM

internal extension NetworkingResult {
    var error: Error? {
        switch self {
        case let .failure(error): return error
        default: return nil
        }
    }

    var data: Data? {
        switch self {
        case let .success(data): return data
        case let .decodableDataFailure(_, data): return data
        default: return nil
        }
    }
}
