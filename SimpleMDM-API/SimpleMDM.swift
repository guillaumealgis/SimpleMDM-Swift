//
//  SimpleMDM.swift
//  SimpleMDM
//
//  Created by Guillaume Algis on 01/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation


public class SimpleMDM: NSObject {
    public static var APIKey: String? {
        get {
            return SimpleMDM.shared.APIKey
        }
        set {
            SimpleMDM.shared.APIKey = newValue
        }
    }

    internal static let shared = SimpleMDM()
    internal let networkController = NetworkController()

    internal var APIKey: String? {
        didSet {
            let utf8Data = APIKey?.data(using: .utf8)
            base64APIKey = utf8Data?.base64EncodedString()
        }
    }
    internal var base64APIKey: String?
}
