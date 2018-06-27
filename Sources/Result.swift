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
        case .success(let value):
            return value
        default:
            return nil
        }
    }
    var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}
