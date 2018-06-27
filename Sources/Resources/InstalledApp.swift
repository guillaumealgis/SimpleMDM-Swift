//
//  InstalledApp.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 14/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct InstalledApp : IdentifiableResource {
    public static var endpointName: String {
        return "installed_apps"
    }

    let name: String
    let identifier: String
    let version: String
    let shortVersion: String
    let bundleSize: Int
    let dynamicSize: Int
    let managed: Bool
    let discoveredAt: Date
}
