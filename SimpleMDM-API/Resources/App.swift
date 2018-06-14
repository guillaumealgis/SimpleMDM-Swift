//
//  App.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 10/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct App : IdentifiableResource, ListableResource {
    public typealias Identifier = Int
    public static var endpointName: String {
        return "apps"
    }

    let name: String
    let appType: String
    let bundleIdentifier: String
    let itunesStoreId: Int?
    let version: String?
}
