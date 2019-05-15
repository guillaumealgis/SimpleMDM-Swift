//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class DeviceGroupTests: XCTestCase {
    func testGetAllDeviceGroups() {
        let json = loadFixture("DeviceGroups")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        DeviceGroup.getAll(s.networking) { result in
            guard case let .success(devices) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(devices.count, 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetADeviceGroup() {
        let json = loadFixture("DeviceGroup_Executives")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        DeviceGroup.get(s.networking, id: 38) { result in
            guard case let .success(device) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(device.name, "Executives")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
