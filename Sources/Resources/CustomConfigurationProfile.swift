//
//  Copyright 2021 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A custom configuration profile created with AppleConfiguration and applied to devices.
public struct CustomConfigurationProfile: ListableResource {
    // sourcery:inline:auto:CustomConfigurationProfile.Identifiable
    /// The unique identifier of this resource.
    public let id: Int
    // sourcery:end

    /// The name of the configuration profile.
    public let name: String

    // MARK: - Relations

    /// The device groups to which the profile is applied.
    public let deviceGroups: RelatedToMany<DeviceGroup>
}
