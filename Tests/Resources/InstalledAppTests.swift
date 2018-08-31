//
//  InstalledAppsTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import XCTest
@testable import SimpleMDM

class InstalledAppsTests: XCTestCase {

    func testGetAnInstalledApp() {
        let json = loadFixture("InstalledApp_Dropbox")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        InstalledApp.get(id: 10446659) { (result) in
            guard case let .success(installedApp) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(installedApp.name, "Dropbox")
        }
    }

}
