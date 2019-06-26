//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

import PromiseKit

/// Alias Result to PromiseKit.Result to prevent a mixup when compiling with Swift 5.
///
/// Once we migrate to PromiseKit 7 this should be removed.
public typealias Result = PromiseKit.Result

/// The main static object representing the SimpleMDM API. Use this to set your private API key.
public class SimpleMDM: NSObject {
    // MARK: - Type properties

    /// Your private SimpleMDM API key.
    ///
    /// You **must** set this property to an non-empty string before using any other object of this library.
    /// Failure to do so will result in most methods returning a `SimpleMDMError.aPIKeyNotSet` error.
    ///
    /// Your API key can be found in your SimpleMDM account, under Settings > API > Secret Access Key.
    public static var apiKey: String? {
        get {
            return SimpleMDM.shared.networking.apiKey
        }
        set {
            SimpleMDM.shared.networking.apiKey = newValue
        }
    }

    internal static let shared = SimpleMDM()

    // MARK: - Instance properties

    internal override init() {}

    internal var networking = Networking()
}
