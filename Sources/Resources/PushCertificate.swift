//
//  PushCertificate.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 15/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct PushCertificate : UniqueResource {
    let appleId: String
    let expiresAt: Date
}
