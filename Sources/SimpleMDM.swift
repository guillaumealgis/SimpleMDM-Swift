//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// The main static object representing the SimpleMDM API. Use this to set your private API key.
public final class SimpleMDM {
    // MARK: - Type properties

    /// Your private SimpleMDM API key.
    ///
    /// You **must** set this property to a non-empty string before using any other object of this library.
    /// Failure to do so will result in most methods returning a `SimpleMDMError.aPIKeyNotSet` error.
    ///
    /// Your API key can be found in your SimpleMDM account, under Settings > API > Secret Access Key.
    public static var apiKey: String? {
        get {
            SimpleMDM.shared.networking.apiKey
        }
        set {
            SimpleMDM.shared.networking.apiKey = newValue
        }
    }

    // This is only kept mutable for tests so we can replace the shared instance with a custom one with mocked
    // sub-components (e.g. Networking).
    static var shared = SimpleMDM()

    // MARK: - Sub-components

    var networking: Networking
    var decoding: Decoding

    // MARK: - Private initializer

    init(networking: Networking = Networking(), decoding: Decoding = Decoding()) {
        self.networking = networking
        self.decoding = decoding
    }
}
