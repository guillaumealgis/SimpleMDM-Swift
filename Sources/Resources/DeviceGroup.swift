//
//  DeviceGroup.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct DeviceGroup: ListableResource {
    // sourcery:inline:auto:DeviceGroup.Identifiable
    public let id: Int
    // sourcery:end

    let name: String
}
