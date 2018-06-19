//
//  AppGroup.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 11/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct AppGroup : IdentifiableResource, ListableResource {
    public typealias Identifier = Int
    public static var endpointName: String {
        return "app_groups"
    }

    let name: String
    let autoDeploy: Bool
}
