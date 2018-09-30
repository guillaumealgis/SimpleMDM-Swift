//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

public extension Device {
    // sourcery: identifierType = String
    struct CustomAttributeValue: IdentifiableResource {
        // sourcery:inline:auto:Device.CustomAttributeValue.Identifiable
        public let id: String
        // sourcery:end

        let value: String
    }
}
