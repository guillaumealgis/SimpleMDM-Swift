//
//  Copyright 2020 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class CustomConfigurationProfileTests: XCTestCase {
    func testGetAllCustomConfigurationProfiles() {
        let json = loadFixture("CustomConfigurationProfiles")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        CustomConfigurationProfile.getAll(s.networking) { result in
            guard case let .fulfilled(customAttributes) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(customAttributes.count, 3)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetACustomConfigurationProfile() {
        let json = loadFixture("CustomConfigurationProfile_MunkiConfiguration")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        CustomConfigurationProfile.get(s.networking, id: 293_814) { result in
            guard case let .fulfilled(customConfigurationProfile) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(customConfigurationProfile.name, "Munki Configuration")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetACustomConfigurationProfileRelatedDeviceGroups() {
        let session = URLSessionMock(routes: [
            "/api/v1/custom_configuration_profiles/293814": Response(data: loadFixture("CustomConfigurationProfile_MunkiConfiguration")),
            "/api/v1/device_groups/38": Response(data: loadFixture("DeviceGroup_Executives"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        CustomConfigurationProfile.get(s.networking, id: 293_814) { ccpResult in
            guard case let .fulfilled(customConfigurationProfile) = ccpResult else {
                return XCTFail("Expected .fulfilled, got \(ccpResult)")
            }
            XCTAssertEqual(customConfigurationProfile.deviceGroups.relatedIds, [38])

            customConfigurationProfile.deviceGroups.getAll(s.networking) { deviceGroupsResult in
                guard case let .fulfilled(deviceGroups) = deviceGroupsResult else {
                    return XCTFail("Expected .fulfilled, got \(deviceGroupsResult)")
                }
                XCTAssertEqual(deviceGroups.map { $0.id }, [38])
                XCTAssertEqual(deviceGroups[0].name, "Executives")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
