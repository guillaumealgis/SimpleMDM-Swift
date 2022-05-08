//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class CustomConfigurationProfileTests: XCTestCase {
    func testGetAllCustomConfigurationProfiles() async throws {
        let json = loadFixture("CustomConfigurationProfiles")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let customAttributes = try await CustomConfigurationProfile.all.collect()
        XCTAssertEqual(customAttributes.count, 3)
    }

    func testGetACustomConfigurationProfile() async throws {
        let json = loadFixture("CustomConfigurationProfile_MunkiConfiguration")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let customConfigurationProfile = try await CustomConfigurationProfile.get(id: 293_814)
        XCTAssertEqual(customConfigurationProfile.name, "Munki Configuration")
    }

    func testGetACustomConfigurationProfileRelatedDeviceGroups() async throws {
        let sessionMock = URLSessionMock(routes: [
            "/api/v1/custom_configuration_profiles/293814": Response(data: loadFixture("CustomConfigurationProfile_MunkiConfiguration")),
            "/api/v1/device_groups/38": Response(data: loadFixture("DeviceGroup_Executives"))
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let expectedIDs = [38]
        let expectedNames = ["Executives"]

        let customConfigurationProfile = try await CustomConfigurationProfile.get(id: 293_814)
        XCTAssertEqual(customConfigurationProfile.deviceGroups.relatedIds, [38])

        var i = 0
        for try await deviceGroup in customConfigurationProfile.deviceGroups {
            XCTAssertEqual(deviceGroup.id, expectedIDs[i])
            XCTAssertEqual(deviceGroup.name, expectedNames[i])
            i += 1
        }
    }
}
