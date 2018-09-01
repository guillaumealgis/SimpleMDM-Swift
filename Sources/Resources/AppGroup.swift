//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

public struct AppGroup: ListableResource {
    // sourcery:inline:auto:AppGroup.Identifiable
    public let id: Int
    // sourcery:end

    let name: String
    let autoDeploy: Bool

    let apps: RelatedToMany<App>
    let deviceGroups: RelatedToMany<DeviceGroup>
    let devices: RelatedToMany<Device>
}
