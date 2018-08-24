//
//  InstalledApp.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 14/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct InstalledApp : IdentifiableResource {
    // sourcery:inline:auto:InstalledApp.Identifiable
    public let id: Int
    // sourcery:end
    
    let name: String
    let identifier: String
    let version: String
    let shortVersion: String
    let bundleSize: Int
    let dynamicSize: Int
    let managed: Bool
    let discoveredAt: Date
}
