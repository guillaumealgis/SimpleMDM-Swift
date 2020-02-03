//
//  Copyright 2020 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// An extension adding `CustomAttributeValue` to all instances of `Device`.
public extension Device {
    // sourcery: identifierType = String
    /// A custom attribute value assigned to a device.
    struct CustomAttributeValue: IdentifiableResource {
        // sourcery:inline:auto:Device.CustomAttributeValue.Identifiable
        /// The unique identifier of this resource.
        public let id: String
        // sourcery:end

        /// The value of the attribute you set for the device.
        public let value: String
    }
}
