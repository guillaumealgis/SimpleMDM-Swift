//
//  DeviceGroupTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

@testable import SimpleMDM
import XCTest

class DeviceGroupTests: XCTestCase {
    func testGetAllDeviceGroups() {
        let json = loadFixture("DeviceGroups")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        DeviceGroup.getAll { result in
            guard case let .success(devices) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(devices.count, 2)
        }
    }

    func testGetADeviceGroup() {
        let json = loadFixture("DeviceGroup_Executives")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        DeviceGroup.get(id: 38) { result in
            guard case let .success(device) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(device.name, "Executives")
        }
    }
}
