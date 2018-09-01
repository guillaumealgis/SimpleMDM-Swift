//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}
