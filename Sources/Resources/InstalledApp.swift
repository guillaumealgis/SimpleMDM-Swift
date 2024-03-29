//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A representation of an app installation on a device.
public struct InstalledApp: GettableResource {
    // sourcery:inline:auto:InstalledApp.Identifiable
    /// The type of the unique identifier of this resource.
    public typealias ID = Int

    /// The unique identifier of this resource.
    public let id: ID
    // sourcery:end

    /// The name of the installed app.
    public let name: String
    /// The bundle identifier of the app (in reverse DNS notation).
    public let identifier: String
    /// The version of the app (corresponding to the `CFBundleVersion` entry in the app's Info.plist).
    public let version: String
    /// The version of the app (corresponding to the `CFBundleShortVersionString` entry in the app's Info.plist).
    public let shortVersion: Version
    /// The size of the installed app on the device, in bytes.
    public let bundleSize: Int
    /// The size of the installed app ???, in bytes.
    public let dynamicSize: Int
    /// Whether the app is managed by SimpleMDM.
    public let managed: Bool
    /// The date at which the app was discovered by SimpleMDM on the device.
    public let discoveredAt: Date
}
