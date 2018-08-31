//
//  Device.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

// sourcery: identifierType = String
public struct CustomAttribute: ListableResource {
    // sourcery:inline:auto:CustomAttribute.Identifiable
    public let id: String
    // sourcery:end

    let name: String
}
