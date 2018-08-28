//
//  AppGroup.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 11/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct AppGroup : ListableResource {
    // sourcery:inline:auto:AppGroup.Identifiable
    public let id: Int
    // sourcery:end

    let name: String
    let autoDeploy: Bool

    let apps: RelatedToMany<App>
    let deviceGroups: RelatedToMany<DeviceGroup>
    let devices: RelatedToMany<Device>
}
