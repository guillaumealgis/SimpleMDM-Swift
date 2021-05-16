//
//  Copyright 2021 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A custom configuration profile created with AppleConfiguration and applied to devices.
public struct CustomConfigurationProfile: ListableResource {
    // sourcery:inline:auto:CustomConfigurationProfile.Identifiable
    /// The type of the unique identifier of this resource.
    public typealias ID = Int

    /// The unique identifier of this resource.
    public let id: ID
    // sourcery:end

    /// The name of the configuration profile.
    public let name: String

    // MARK: - Relations

    /// The device groups to which the profile is applied.
    public let deviceGroups: RelatedToMany<DeviceGroup>
}
