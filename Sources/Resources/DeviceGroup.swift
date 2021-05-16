//
//  Copyright 2021 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A group of device, used to assign apps and profiles to devices.
public struct DeviceGroup: ListableResource {
    // sourcery:inline:auto:DeviceGroup.Identifiable
    /// The type of the unique identifier of this resource.
    public typealias ID = Int

    /// The unique identifier of this resource.
    public let id: ID
    // sourcery:end

    /// The name of the device group.
    public let name: String
}
