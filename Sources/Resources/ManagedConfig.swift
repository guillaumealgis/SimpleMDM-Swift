//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

public extension App {
    // sourcery: identifierType = Int
    struct ManagedConfig: ListableResource {
        // sourcery:inline:auto:App.ManagedConfig.Identifiable
        public let id: Int
        // sourcery:end

        let key: String
        let value: String
        let valueType: String
    }
}
