//
//  InstalledAppsTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

@testable import SimpleMDM
import XCTest

class InstalledAppsTests: XCTestCase {
    func testGetAnInstalledApp() {
        let json = loadFixture("InstalledApp_Dropbox")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        // swiftformat:disable:next numberFormatting
        InstalledApp.get(id: 10446659) { result in
            guard case let .success(installedApp) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(installedApp.name, "Dropbox")
        }
    }
}
