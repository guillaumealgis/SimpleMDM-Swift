//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// An app group is an object that pairs `App` resources with `DeviceGroup` resources for the purpose of pushing apps
/// to devices.
public struct AppGroup: ListableResource {
    // sourcery:inline:auto:AppGroup.Identifiable
    /// The unique identifier of this resource.
    public let id: Int
    // sourcery:end

    /// The name of the group.
    public let name: String
    /// Weither the apps in this group are deployed automatically to the devices in this group.
    public let autoDeploy: Bool

    // MARK: - Relations

    /// The apps in this app group.
    public let apps: RelatedToMany<App>
    /// The groups of devices to which the apps in this group will be deployed on.
    public let deviceGroups: RelatedToMany<DeviceGroup>
    /// Other devices to which the apps in this group will be deployed on.
    public let devices: RelatedToMany<Device>
}
