//
//  Device.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct Device : Resource {
    public static var endpointName: String {
        return "devices"
    }

    public let name: String
}

