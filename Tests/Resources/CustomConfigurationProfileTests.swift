//
//  CustomConfigurationProfileTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import XCTest
@testable import SimpleMDM

class CustomConfigurationProfileTests: XCTestCase {

    func testGetAllCustomConfigurationProfiles() {
        let json = loadFixture("CustomConfigurationProfiles")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomConfigurationProfile.getAll { (result) in
            guard case let .success(customAttributes) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(customAttributes.count, 3)
        }
    }

    func testGetACustomConfigurationProfile() {
        let json = loadFixture("CustomConfigurationProfile_MunkiConfiguration")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomConfigurationProfile.get(id: 293814) { (result) in
            guard case let .success(customConfigurationProfile) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(customConfigurationProfile.name, "Munki Configuration")
        }
    }

    func testGetACustomConfigurationProfileRelatedDeviceGroups() {
        let session = URLSessionMock(routes: [
            "/api/v1/custom_configuration_profiles/293814": Response(data: loadFixture("CustomConfigurationProfile_MunkiConfiguration")),
            "/api/v1/device_groups/38": Response(data: loadFixture("DeviceGroup_Executives")),
            ])
        SimpleMDM.useSessionMock(session)

        CustomConfigurationProfile.get(id: 293814) { (ccpResult) in
            guard case let .success(customConfigurationProfile) = ccpResult else {
                return XCTFail("Expected .success, got \(ccpResult)")
            }
            XCTAssertEqual(customConfigurationProfile.deviceGroups.relatedIds, [38])

            customConfigurationProfile.deviceGroups.getAll(completion: { (deviceGroupsResult) in
                guard case let .success(deviceGroups) = deviceGroupsResult else {
                    return XCTFail("Expected .success, got \(deviceGroupsResult)")
                }
                XCTAssertEqual(deviceGroups.map({ $0.id }), [38])
                XCTAssertEqual(deviceGroups[0].name, "Executives")
            })
        }
    }

}
