//
//  SimpleMDM.swift
//  SimpleMDM
//
//  Created by Guillaume Algis on 01/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation


public class SimpleMDM: NSObject {

    // MARK: Type properties

    public static var APIKey: String? {
        get {
            return SimpleMDM.shared.networkController.APIKey
        }
        set {
            SimpleMDM.shared.networkController.APIKey = newValue
        }
    }

    internal static let shared = SimpleMDM()

    // MARK: Instance properties

    private override init() {}

    internal var networkController = NetworkController()
}
