//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// An `App` represents an app in your app catalog. You can use `AppGroup` to install apps to your devices.
public struct App: ListableResource {
    // sourcery:inline:auto:App.Identifiable
    /// The unique identifier of this resource.
    public let id: Int
    // sourcery:end

    /// The name of the app.
    public let name: String
    /// The app type (e.g. "app store", "enterprise", etc.)
    public let appType: String
    /// The bundle identifier of the app (in reverse DNS notation).
    public let bundleIdentifier: String
    /// The iTunes store id of the app (if the app is available on the App Store or Mac App Store).
    public let itunesStoreId: Int?
    /// The version of the app (corresponding to the `CFBundleVersion` entry in the app's Info.plist).
    public let version: String?

    // MARK: - Relations

    /// Managed app configuration associated with the app.
    public let managedConfigs: NestedResourceCursor<App, ManagedConfig>
}
