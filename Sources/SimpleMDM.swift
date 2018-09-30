//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

public class SimpleMDM: NSObject {
    // MARK: Type properties

    public static var APIKey: String? {
        get {
            return SimpleMDM.shared.networking.APIKey
        }
        set {
            SimpleMDM.shared.networking.APIKey = newValue
        }
    }

    internal static let shared = SimpleMDM()

    // MARK: Instance properties

    private override init() {}

    internal var networking = Networking()
    internal var decodingService = DecodingService()
}
