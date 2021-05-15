//
//  Copyright 2021 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// The Apple push certificate used by SimpleMDM to push configuration update to your devices.
public struct PushCertificate: UniqueResource {
    /// The Apple id of the certificate.
    public let appleId: String
    /// The expiration date of the certificate.
    public let expiresAt: Date
}
