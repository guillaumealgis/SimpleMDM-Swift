//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// An enum used to represent failable asynchronous operations results throughout the library.
///
/// See [John Sundell's blog on this](https://www.swiftbysundell.com/posts/the-power-of-result-types-in-swift) for
/// more details.
public enum Result<Value> {
    /// The operation was successful.
    case success(Value)
    /// The operation was a failure.
    case failure(Error)
}
