//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// Your SimpleMDM account.
public struct Account: UniqueResource {
    /// The name of the account.
    public let name: String
    /// The app store country that SimpleMDM uses for the account (in ISO 3166-1 alpha-2 format).
    public let appleStoreCountryCode: String
}
