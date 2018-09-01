//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

class DeviceTests: XCTestCase {
    func testGetAllDevices() {
        let json = loadFixture("Devices")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Device.getAll { result in
            guard case let .success(devices) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(devices.count, 2)
        }
    }

    func testGetADevice() {
        let json = loadFixture("Device_MikesiPhone")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { result in
            guard case let .success(device) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(device.name, "Mike's iPhone")
        }
    }

    func testGetADeviceRelatedDeviceGroup() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/device_groups/37": Response(data: loadFixture("DeviceGroup_Interns"))
        ])
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }
            XCTAssertEqual(device.deviceGroup.relatedId, 37)

            device.deviceGroup.get(completion: { deviceGroupResult in
                guard case let .success(deviceGroup) = deviceGroupResult else {
                    return XCTFail("Expected .success, got \(deviceGroupResult)")
                }
                XCTAssertEqual(deviceGroup.name, "Interns")
            })
        }
    }

    func testErrorWhileFetchingRelatedToOne() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/device_groups/37": Response(data: Data(), code: 404)
        ])
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }
            XCTAssertEqual(device.deviceGroup.relatedId, 37)

            device.deviceGroup.get(completion: { deviceGroupResult in
                guard case let .failure(error) = deviceGroupResult else {
                    return XCTFail("Expected .failure, got \(deviceGroupResult)")
                }
                guard let apiError = error as? APIError else {
                    return XCTFail("Expected error to be an APIError, got \(error)")
                }
                XCTAssertEqual(apiError, APIError.doesNotExist)
            })
        }
    }
}
