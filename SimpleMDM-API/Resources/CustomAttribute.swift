//
//  Device.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct CustomAttribute : Resource {
    public typealias Identifier = String
    public static var endpointName: String {
        return "custom_attributes"
    }

    let name: String
}
