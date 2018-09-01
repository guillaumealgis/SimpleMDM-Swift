//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
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
