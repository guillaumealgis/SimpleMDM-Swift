//
//  Utils.swift
//  Tests
//
//  Created by Guillaume Algis on 10/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

@testable import SimpleMDM

extension SimpleMDM {
    class func useSessionMock(_ session: URLSessionMock) {
        let networkController = NetworkController(urlSession: session)
        networkController.APIKey = "AVeryRandomTestAPIKey"
        shared.overrideNetworkController(networkController: networkController)
    }

    func overrideNetworkController(networkController: NetworkController) {
        self.networkController = networkController
    }
}
