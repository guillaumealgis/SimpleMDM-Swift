//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

public struct PushCertificate: UniqueResource {
    let appleId: String
    let expiresAt: Date
}
