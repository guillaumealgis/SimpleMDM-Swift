//
//  Utils.swift
//  Tests
//
//  Created by Guillaume Algis on 10/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

@testable import SimpleMDM

func loadFixture(_ name: String) -> Data {
    let bundle = Bundle(for: ResourcesTests.self)
    let urlIfFound = bundle.url(forResource: name, withExtension: "json")
    guard let url = urlIfFound else {
        fatalError("Fixture \"\(name)\" not found in bundle \(bundle)")
    }
    let fixture = try! Data(contentsOf: url)
    return fixture
}

extension SimpleMDM {
    class func useSessionMock(_ session: URLSessionMock) {
        let networkController = NetworkController(urlSession: session)
        shared.overrideNetworkController(networkController: networkController)
        SimpleMDM.APIKey = "AVeryRandomTestAPIKey"
    }

    func overrideNetworkController(networkController: NetworkController) {
        self.networkController = networkController
    }
}
