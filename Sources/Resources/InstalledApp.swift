//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

public struct InstalledApp: GettableResource {
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
