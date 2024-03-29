//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// An extension adding `CustomAttributeValue` to all instances of `Device`.
public extension Device {
    // sourcery: identifierType = String
    /// A custom attribute value assigned to a device.
    struct CustomAttributeValue: ListableResource {
        // sourcery:inline:auto:Device.CustomAttributeValue.Identifiable
        /// The type of the unique identifier of this resource.
        public typealias ID = String

        /// The unique identifier of this resource.
        public let id: ID
        // sourcery:end

        /// The value of the attribute you set for the device.
        public let value: String
    }
}
