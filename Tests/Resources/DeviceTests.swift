//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

////
////  Copyright 2021 Guillaume Algis.
////  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
////
//
// @testable import SimpleMDM
// import XCTest
//
// internal class DeviceTests: XCTestCase {
//    func testGetAllDevices() async throws {
//        let json = loadFixture("Devices")
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        Device.getAll() { result in
//            guard case let .fulfilled(devices) = result else {
//                return XCTFail("Expected .fulfilled, got \(result)")
//            }
//            XCTAssertEqual(devices.count, 2)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testGetADevice() async throws {
//        let json = loadFixture("Device_MikesiPhone")
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        Device.get(id: 121) { result in
//            guard case let .fulfilled(device) = result else {
//                return XCTFail("Expected .fulfilled, got \(result)")
//            }
//            XCTAssertEqual(device.name, "Mike's iPhone")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testGetADeviceRelatedDeviceGroup() async throws {
//        let sessionMock = URLSessionMock(routes: [
//            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
//            "/api/v1/device_groups/37": Response(data: loadFixture("DeviceGroup_Interns"))
//        ])
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        Device.get(id: 121) { deviceResult in
//            guard case let .fulfilled(device) = deviceResult else {
//                return XCTFail("Expected .fulfilled, got \(deviceResult)")
//            }
//            XCTAssertEqual(device.deviceGroup.relatedId, 37)
//
//            device.deviceGroup.get() { deviceGroupResult in
//                guard case let .fulfilled(deviceGroup) = deviceGroupResult else {
//                    return XCTFail("Expected .fulfilled, got \(deviceGroupResult)")
//                }
//                XCTAssertEqual(deviceGroup.name, "Interns")
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testErrorWhileFetchingRelatedToOne() async throws {
//        let sessionMock = URLSessionMock(routes: [
//            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
//            "/api/v1/device_groups/37": Response(data: Data(), code: 404)
//        ])
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        Device.get(id: 121) { deviceResult in
//            guard case let .fulfilled(device) = deviceResult else {
//                return XCTFail("Expected .fulfilled, got \(deviceResult)")
//            }
//            XCTAssertEqual(device.deviceGroup.relatedId, 37)
//
//            device.deviceGroup.get() { deviceGroupResult in
//                guard case let .rejected(error) = deviceGroupResult else {
//                    return XCTFail("Expected .rejected, got \(deviceGroupResult)")
//                }
//                guard let simpleMDMError = error as? SimpleMDMError else {
//                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//                }
//                XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testErrorWhileFetchingADeviceRelatedCustomAttributeById() async throws {
//        let json = """
//          {
//            "errors": []
//          }
//        """.data(using: .utf8)
//
//        let sessionMock = URLSessionMock(routes: [
//            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
//            "/api/v1/devices/121/custom_attribute_values": Response(data: json, code: 500)
//        ])
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        Device.get(id: 121) { deviceResult in
//            guard case let .fulfilled(device) = deviceResult else {
//                return XCTFail("Expected .fulfilled, got \(deviceResult)")
//            }
//
//            device.customAttributes.get(id: "device_color") { customAttributesResult in
//                guard case let .rejected(error) = customAttributesResult else {
//                    return XCTFail("Expected .rejected, got \(customAttributesResult)")
//                }
//                guard let simpleMDMError = error as? SimpleMDMError else {
//                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//                }
//                XCTAssertEqual(simpleMDMError, SimpleMDMError.unknown(httpCode: 500))
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testGetADeviceRelatedCustomAttributeValues() async throws {
//        let sessionMock = URLSessionMock(routes: [
//            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
//            "/api/v1/devices/121/custom_attribute_values": Response(data: loadFixture("Device_MikesiPhone_CustomAttributeValues"))
//        ])
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        Device.get(id: 121) { deviceResult in
//            guard case let .fulfilled(device) = deviceResult else {
//                return XCTFail("Expected .fulfilled, got \(deviceResult)")
//            }
//
//            device.customAttributes.getAll() { customAttributesResult in
//                guard case let .fulfilled(customAttributes) = customAttributesResult else {
//                    return XCTFail("Expected .fulfilled, got \(customAttributesResult)")
//                }
//                XCTAssertEqual(customAttributes.map { $0.id }, ["device_color", "year_purchased"])
//                XCTAssertEqual(customAttributes.map { $0.value }, ["space gray", "2018"])
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testGetADeviceRelatedCustomAttributeValueById() async throws {
//        let sessionMock = URLSessionMock(routes: [
//            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
//            "/api/v1/devices/121/custom_attribute_values": Response(data: loadFixture("Device_MikesiPhone_CustomAttributeValues"))
//        ])
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        Device.get(id: 121) { deviceResult in
//            guard case let .fulfilled(device) = deviceResult else {
//                return XCTFail("Expected .fulfilled, got \(deviceResult)")
//            }
//
//            device.customAttributes.get(id: "device_color") { customAttributesResult in
//                guard case let .fulfilled(customAttribute) = customAttributesResult else {
//                    return XCTFail("Expected .fulfilled, got \(customAttributesResult)")
//                }
//                XCTAssertEqual(customAttribute.value, "space gray")
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testGetADeviceRelatedCustomAttributeValueWithNonexistentId() async throws {
//        let sessionMock = URLSessionMock(routes: [
//            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
//            "/api/v1/devices/121/custom_attribute_values": Response(data: loadFixture("Device_MikesiPhone_CustomAttributeValues"))
//        ])
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        Device.get(id: 121) { deviceResult in
//            guard case let .fulfilled(device) = deviceResult else {
//                return XCTFail("Expected .fulfilled, got \(deviceResult)")
//            }
//
//            device.customAttributes.get(id: "nonexistent_attribute") { customAttributesResult in
//                guard case let .rejected(error) = customAttributesResult else {
//                    return XCTFail("Expected .rejected, got \(customAttributesResult)")
//                }
//                guard let simpleMDMError = error as? SimpleMDMError else {
//                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//                }
//                XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testSearchForADevice() async throws {
//        let sessionMock = URLSessionMock(routes: [
//            "/api/v1/devices?search=iPhone": Response(data: loadFixture("Devices"))
//        ])
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        let cursor = SearchCursor<Device>(searchString: "iPhone")
//        cursor.next() { searchResult in
//            guard case let .fulfilled(devices) = searchResult else {
//                return XCTFail("Expected .fulfilled, got \(searchResult)")
//            }
//            XCTAssertEqual(devices.count, 2)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
// }
