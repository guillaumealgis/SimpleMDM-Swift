//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class AppGroupTests: XCTestCase {
    func testGetAllAppGroups() {
        let json = loadFixture("AppGroups")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        AppGroup.getAll(s.networking) { result in
            guard case let .fulfilled(appGroups) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(appGroups.count, 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetAnAppGroup() {
        let json = loadFixture("AppGroup_ProductivityApps")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        AppGroup.get(s.networking, id: 38) { result in
            guard case let .fulfilled(appGroup) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(appGroup.name, "Productivity Apps")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testErrorWhileFetchingRelatedToMany() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello")),
            "/api/v1/apps/67": Response(data: Data(), code: 404)
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        AppGroup.get(s.networking, id: 38) { appGroupResult in
            guard case let .fulfilled(appGroup) = appGroupResult else {
                return XCTFail("Expected .fulfilled, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(s.networking) { appsResult in
                guard case let .rejected(error) = appsResult else {
                    return XCTFail("Expected .rejected, got \(appsResult)")
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

    func testFetchingRelatedToManyAsynchronouslyWithDelay() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello"), delay: .milliseconds(50)),
            "/api/v1/apps/67": Response(data: loadFixture("App_Evernote"), delay: .milliseconds(10))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        AppGroup.get(s.networking, id: 38) { appGroupResult in
            guard case let .fulfilled(appGroup) = appGroupResult else {
                return XCTFail("Expected .fulfilled, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(s.networking) { appsResult in
                guard case let .fulfilled(apps) = appsResult else {
                    return XCTFail("Expected .fulfilled, got \(appsResult)")
                }
                XCTAssertEqual(apps.map { $0.id }, [63, 67])
                XCTAssertEqual(apps[0].name, "Trello")
                XCTAssertEqual(apps[1].name, "Evernote")

                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetAnAppGroupRelatedApps() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello")),
            "/api/v1/apps/67": Response(data: loadFixture("App_Evernote"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        AppGroup.get(s.networking, id: 38) { appGroupResult in
            guard case let .fulfilled(appGroup) = appGroupResult else {
                return XCTFail("Expected .fulfilled, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(s.networking) { appsResult in
                guard case let .fulfilled(apps) = appsResult else {
                    return XCTFail("Expected .fulfilled, got \(appsResult)")
                }
                XCTAssertEqual(apps.map { $0.id }, [63, 67])
                XCTAssertEqual(apps[0].name, "Trello")
                XCTAssertEqual(apps[1].name, "Evernote")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetAnAppGroupRelatedDeviceGroups() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/device_groups/37": Response(data: loadFixture("DeviceGroup_Interns")),
            "/api/v1/device_groups/38": Response(data: loadFixture("DeviceGroup_Executives"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        AppGroup.get(s.networking, id: 38) { appGroupResult in
            guard case let .fulfilled(appGroup) = appGroupResult else {
                return XCTFail("Expected .fulfilled, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.deviceGroups.relatedIds, [37, 38])

            appGroup.deviceGroups.getAll(s.networking) { deviceGroupsResult in
                guard case let .fulfilled(deviceGroups) = deviceGroupsResult else {
                    return XCTFail("Expected .fulfilled, got \(deviceGroupsResult)")
                }
                XCTAssertEqual(deviceGroups.map { $0.id }, [37, 38])
                XCTAssertEqual(deviceGroups[0].name, "Interns")
                XCTAssertEqual(deviceGroups[1].name, "Executives")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetAnAppGroupRelatedDevices() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        AppGroup.get(s.networking, id: 38) { appGroupResult in
            guard case let .fulfilled(appGroup) = appGroupResult else {
                return XCTFail("Expected .fulfilled, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.devices.relatedIds, [121])

            appGroup.devices.getAll(s.networking) { devicesResult in
                guard case let .fulfilled(devices) = devicesResult else {
                    return XCTFail("Expected .fulfilled, got \(devicesResult)")
                }
                XCTAssertEqual(devices.map { $0.id }, [121])
                XCTAssertEqual(devices[0].name, "Mike's iPhone")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetAnAppGroupRelatedDeviceAtPosition() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        AppGroup.get(s.networking, id: 38) { appGroupResult in
            guard case let .fulfilled(appGroup) = appGroupResult else {
                return XCTFail("Expected .fulfilled, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.devices.relatedIds, [121])

            appGroup.devices.get(s.networking, at: 0) { deviceResult in
                guard case let .fulfilled(device) = deviceResult else {
                    return XCTFail("Expected .fulfilled, got \(deviceResult)")
                }
                XCTAssertEqual(device.name, "Mike's iPhone")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetAnAppGroupRelatedDeviceById() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        AppGroup.get(s.networking, id: 38) { appGroupResult in
            guard case let .fulfilled(appGroup) = appGroupResult else {
                return XCTFail("Expected .fulfilled, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.devices.relatedIds, [121])

            appGroup.devices.get(s.networking, id: 121) { deviceResult in
                guard case let .fulfilled(device) = deviceResult else {
                    return XCTFail("Expected .fulfilled, got \(deviceResult)")
                }
                XCTAssertEqual(device.name, "Mike's iPhone")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
