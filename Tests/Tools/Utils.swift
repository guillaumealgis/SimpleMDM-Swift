//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

@testable import SimpleMDM

internal func loadFixture(_ name: String) -> Data {
    let bundle = Bundle(for: ResourcesTests.self)
    let urlIfFound = bundle.url(forResource: name, withExtension: "json")
    guard let url = urlIfFound else {
        fatalError("Fixture \"\(name)\" not found in bundle \(bundle)")
    }
    guard let fixture = try? Data(contentsOf: url) else {
        fatalError("Error loading data at URL \"\(url)\"")
    }
    return fixture
}

internal extension SimpleMDM {
    class func useSessionMock(_ sessionMock: URLSessionMock? = nil) {
        let session = sessionMock ?? URLSessionMock()
        let networking = Networking(urlSession: session)
        networking.APIKey = "AVeryRandomAPIKey"
        shared.overridenetworking(networking)
    }

    func overridenetworking(_ networking: Networking) {
        self.networking = networking
    }
}
