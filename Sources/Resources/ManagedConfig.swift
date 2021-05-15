//
//  Copyright 2021 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// An extension adding `ManagedConfig` to all instances of `App`.
public extension App {
    // sourcery: identifierType = Int
    /// A managed app configuration (a key-value pair) associated with an `App`.
    struct ManagedConfig: ListableResource {
        // sourcery:inline:auto:App.ManagedConfig.Identifiable
        /// The unique identifier of this resource.
        public let id: Int
        // sourcery:end

        /// The key of the managed configuration.
        public let key: String
        /// The value of the managed configuration.
        public let value: String
        /// The type of the value of the managed configuration (e.g. "string", "integer", "string array", etc.).
        public let valueType: String
    }
}
