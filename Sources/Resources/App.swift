//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
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

    let managedConfigs: NestedResourceCursor<App, ManagedConfig>
}
