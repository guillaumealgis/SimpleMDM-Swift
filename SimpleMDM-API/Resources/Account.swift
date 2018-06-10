//
//  Account.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 05/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct Account : UniqueResource {
    public static var endpointName: String {
        return "account"
    }

    let name: String
    let appleStoreCountryCode: String
}
