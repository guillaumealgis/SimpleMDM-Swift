//
//  Device.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct CustomConfigurationProfile : ListableResource {
    public typealias Identifier = Int
    public static var endpointName: String {
        return "custom_configuration_profiles"
    }

    let name: String
}
