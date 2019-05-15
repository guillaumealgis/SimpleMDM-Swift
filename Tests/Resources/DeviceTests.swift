//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class DeviceTests: XCTestCase {
    func testGetAllDevices() {
        let json = loadFixture("Devices")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.getAll(s.networking) { result in
            guard case let .success(devices) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(devices.count, 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetADevice() {
        let json = loadFixture("Device_MikesiPhone")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.get(s.networking, id: 121) { result in
            guard case let .success(device) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(device.name, "Mike's iPhone")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetADeviceRelatedDeviceGroup() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/device_groups/37": Response(data: loadFixture("DeviceGroup_Interns"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.get(s.networking, id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }
            XCTAssertEqual(device.deviceGroup.relatedId, 37)

            device.deviceGroup.get(s.networking) { deviceGroupResult in
                guard case let .success(deviceGroup) = deviceGroupResult else {
                    return XCTFail("Expected .success, got \(deviceGroupResult)")
                }
                XCTAssertEqual(deviceGroup.name, "Interns")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testErrorWhileFetchingRelatedToOne() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/device_groups/37": Response(data: Data(), code: 404)
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.get(s.networking, id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }
            XCTAssertEqual(device.deviceGroup.relatedId, 37)

            device.deviceGroup.get(s.networking) { deviceGroupResult in
                guard case let .failure(error) = deviceGroupResult else {
                    return XCTFail("Expected .failure, got \(deviceGroupResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
                }
                XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testErrorWhileFetchingADeviceRelatedCustomAttributeById() {
        let json = """
          {
            "errors": []
          }
        """.data(using: .utf8)

        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/devices/121/custom_attribute_values": Response(data: json, code: 500)
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.get(s.networking, id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }

            device.customAttributes.get(s.networking, id: "device_color") { customAttributesResult in
                guard case let .failure(error) = customAttributesResult else {
                    return XCTFail("Expected .failure, got \(customAttributesResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
                }
                XCTAssertEqual(simpleMDMError, SimpleMDMError.unknown(httpCode: 500))
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetADeviceRelatedCustomAttributeValues() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/devices/121/custom_attribute_values": Response(data: loadFixture("Device_MikesiPhone_CustomAttributeValues"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.get(s.networking, id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }

            device.customAttributes.getAll(s.networking) { customAttributesResult in
                guard case let .success(customAttributes) = customAttributesResult else {
                    return XCTFail("Expected .success, got \(customAttributesResult)")
                }
                XCTAssertEqual(customAttributes.map { $0.id }, ["device_color", "year_purchased"])
                XCTAssertEqual(customAttributes.map { $0.value }, ["space gray", "2018"])
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetADeviceRelatedCustomAttributeValueById() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/devices/121/custom_attribute_values": Response(data: loadFixture("Device_MikesiPhone_CustomAttributeValues"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.get(s.networking, id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }

            device.customAttributes.get(s.networking, id: "device_color") { customAttributesResult in
                guard case let .success(customAttribute) = customAttributesResult else {
                    return XCTFail("Expected .success, got \(customAttributesResult)")
                }
                XCTAssertEqual(customAttribute.value, "space gray")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetADeviceRelatedCustomAttributeValueWithNonexistentId() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/devices/121/custom_attribute_values": Response(data: loadFixture("Device_MikesiPhone_CustomAttributeValues"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.get(s.networking, id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }

            device.customAttributes.get(s.networking, id: "nonexistent_attribute") { customAttributesResult in
                guard case let .failure(error) = customAttributesResult else {
                    return XCTFail("Expected .failure, got \(customAttributesResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
                }
                XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testSearchForADevice() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices?search=iPhone": Response(data: loadFixture("Devices"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        let cursor = SearchCursor<Device>(searchString: "iPhone")
        cursor.next(s.networking) { searchResult in
            guard case let .success(devices) = searchResult else {
                return XCTFail("Expected .success, got \(searchResult)")
            }
            XCTAssertEqual(devices.count, 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
