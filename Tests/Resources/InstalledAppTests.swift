//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class InstalledAppsTests: XCTestCase {
    func testGetAnInstalledApp() async throws {
        let json = loadFixture("InstalledApp_Dropbox")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let installedApp = try await InstalledApp.get(id: 10_446_659)
        XCTAssertEqual(installedApp.name, "Dropbox")
    }
}
