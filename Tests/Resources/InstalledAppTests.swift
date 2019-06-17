//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class InstalledAppsTests: XCTestCase {
    func testGetAnInstalledApp() {
        let json = loadFixture("InstalledApp_Dropbox")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        InstalledApp.get(s.networking, id: 10_446_659) { result in
            guard case let .fulfilled(installedApp) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(installedApp.name, "Dropbox")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
