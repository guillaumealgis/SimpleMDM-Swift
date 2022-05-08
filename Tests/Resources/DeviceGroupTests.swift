//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class DeviceGroupTests: XCTestCase {
    func testGetAllDeviceGroups() async throws {
        let json = loadFixture("DeviceGroups")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let deviceGroups = try await DeviceGroup.all.collect()
        XCTAssertEqual(deviceGroups.count, 2)
    }

    func testGetADeviceGroup() async throws {
        let json = loadFixture("DeviceGroup_Executives")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let deviceGroup = try await DeviceGroup.get(id: 38)
        XCTAssertEqual(deviceGroup.name, "Executives")
    }
}
