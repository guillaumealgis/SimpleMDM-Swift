//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// The main static object representing the SimpleMDM API. Use this to set your private API key.
public class SimpleMDM: NSObject {
    // MARK: - Type properties

    /// Your private SimpleMDM API key.
    ///
    /// You **must** set this property to an non-empty string before using any other object of this library.
    /// Failure to do so will result in most methods returning a `SimpleMDMError.APIKeyNotSet` error.
    ///
    /// Your API key can be found in your SimpleMDM account, under Settings > API > Secret Access Key.
    public static var APIKey: String? {
        get {
            return SimpleMDM.shared.networking.APIKey
        }
        set {
            SimpleMDM.shared.networking.APIKey = newValue
        }
    }

    internal static let shared = SimpleMDM()

    // MARK: - Instance properties

    internal override init() {}

    internal var networking = Networking()
}
