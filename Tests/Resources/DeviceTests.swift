//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class DeviceTests: XCTestCase {
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

            device.deviceGroup.get { deviceGroupResult in
                guard case let .success(deviceGroup) = deviceGroupResult else {
                    return XCTFail("Expected .success, got \(deviceGroupResult)")
                }
                XCTAssertEqual(deviceGroup.name, "Interns")
            }
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

            device.deviceGroup.get { deviceGroupResult in
                guard case let .failure(error) = deviceGroupResult else {
                    return XCTFail("Expected .failure, got \(deviceGroupResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
                }
                XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
            }
        }
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
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }

            device.customAttributes.get("device_color") { customAttributesResult in
                guard case let .failure(error) = customAttributesResult else {
                    return XCTFail("Expected .failure, got \(customAttributesResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
                }
                XCTAssertEqual(simpleMDMError, SimpleMDMError.unknown(httpCode: 500))
            }
        }
    }

    func testGetADeviceRelatedCustomAttributeValues() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/devices/121/custom_attribute_values": Response(data: loadFixture("Device_MikesiPhone_CustomAttributeValues"))
        ])
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }

            device.customAttributes.getAll { customAttributesResult in
                guard case let .success(customAttributes) = customAttributesResult else {
                    return XCTFail("Expected .success, got \(customAttributesResult)")
                }
                XCTAssertEqual(customAttributes.map { $0.id }, ["device_color", "year_purchased"])
                XCTAssertEqual(customAttributes.map { $0.value }, ["space gray", "2018"])
            }
        }
    }

    func testGetADeviceRelatedCustomAttributeValueById() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/devices/121/custom_attribute_values": Response(data: loadFixture("Device_MikesiPhone_CustomAttributeValues"))
        ])
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }

            device.customAttributes.get("device_color") { customAttributesResult in
                guard case let .success(customAttribute) = customAttributesResult else {
                    return XCTFail("Expected .success, got \(customAttributesResult)")
                }
                XCTAssertEqual(customAttribute.value, "space gray")
            }
        }
    }

    func testGetADeviceRelatedCustomAttributeValueWithNonexistentId() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/devices/121/custom_attribute_values": Response(data: loadFixture("Device_MikesiPhone_CustomAttributeValues"))
        ])
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { deviceResult in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }

            device.customAttributes.get("nonexistent_attribute") { customAttributesResult in
                guard case let .failure(error) = customAttributesResult else {
                    return XCTFail("Expected .failure, got \(customAttributesResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
                }
                XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
            }
        }
    }
}
