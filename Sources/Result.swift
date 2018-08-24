//
//  Result.swift
//  SimpleMDM
//
//  Created by Guillaume Algis on 28/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Error)

    var value: Value? {
        switch self {
        case let .success(value): return value
        case .failure: return nil
        }
    }

    var error: Error? {
        switch self {
        case let .failure(error): return error
        case .success: return nil
        }
    }
}
