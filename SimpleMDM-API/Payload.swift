//
//  Payload.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 06/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

internal struct Payload<T: Resource>: Decodable {
    let data: PayloadData<T>
}

internal struct PayloadData<T: Resource>: Decodable {
    let type: String
    let attributes: T
}
