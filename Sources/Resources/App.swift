//
//  App.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 10/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct App: ListableResource {
    // sourcery:inline:auto:App.Identifiable
    public let id: Int
    // sourcery:end

    let name: String
    let appType: String
    let bundleIdentifier: String
    let itunesStoreId: Int?
    let version: String?
}
