//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

class AppGroupTests: XCTestCase {
    func testGetAllAppGroups() {
        let json = loadFixture("AppGroups")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        AppGroup.getAll { result in
            guard case let .success(appGroups) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(appGroups.count, 2)
        }
    }

    func testGetAnAppGroup() {
        let json = loadFixture("AppGroup_ProductivityApps")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { result in
            guard case let .success(appGroup) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(appGroup.name, "Productivity Apps")
        }
    }

    func testErrorWhileFetchingRelatedToMany() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello")),
            "/api/v1/apps/67": Response(data: Data(), code: 404)
        ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { appGroupResult in
            guard case let .success(appGroup) = appGroupResult else {
                return XCTFail("Expected .success, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(completion: { appsResult in
                guard case let .failure(error) = appsResult else {
                    return XCTFail("Expected .failure, got \(appsResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
                }
                XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
            })
        }
    }

    func testFetchingRelatedToManyAsynchronouslyWithDelay() {
        let expectation = XCTestExpectation(description: "testFetchingRelatedToManyAsynchronouslyWithDelay expectation")
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello"), delay: .milliseconds(50)),
            "/api/v1/apps/67": Response(data: loadFixture("App_Evernote"), delay: .milliseconds(10))
        ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { appGroupResult in
            guard case let .success(appGroup) = appGroupResult else {
                return XCTFail("Expected .success, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(completion: { appsResult in
                guard case let .success(apps) = appsResult else {
                    return XCTFail("Expected .success, got \(appsResult)")
                }
                XCTAssertEqual(apps.map({ $0.id }), [63, 67])
                XCTAssertEqual(apps[0].name, "Trello")
                XCTAssertEqual(apps[1].name, "Evernote")

                expectation.fulfill()
            })
        }

        let result = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(result, .completed)
    }

    func testGetAnAppGroupRelatedApps() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello")),
            "/api/v1/apps/67": Response(data: loadFixture("App_Evernote"))
        ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { appGroupResult in
            guard case let .success(appGroup) = appGroupResult else {
                return XCTFail("Expected .success, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(completion: { appsResult in
                guard case let .success(apps) = appsResult else {
                    return XCTFail("Expected .success, got \(appsResult)")
                }
                XCTAssertEqual(apps.map({ $0.id }), [63, 67])
                XCTAssertEqual(apps[0].name, "Trello")
                XCTAssertEqual(apps[1].name, "Evernote")
            })
        }
    }

    func testGetAnAppGroupRelatedDeviceGroups() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/device_groups/37": Response(data: loadFixture("DeviceGroup_Interns")),
            "/api/v1/device_groups/38": Response(data: loadFixture("DeviceGroup_Executives"))
        ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { appGroupResult in
            guard case let .success(appGroup) = appGroupResult else {
                return XCTFail("Expected .success, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.deviceGroups.relatedIds, [37, 38])

            appGroup.deviceGroups.getAll(completion: { deviceGroupsResult in
                guard case let .success(deviceGroups) = deviceGroupsResult else {
                    return XCTFail("Expected .success, got \(deviceGroupsResult)")
                }
                XCTAssertEqual(deviceGroups.map({ $0.id }), [37, 38])
                XCTAssertEqual(deviceGroups[0].name, "Interns")
                XCTAssertEqual(deviceGroups[1].name, "Executives")
            })
        }
    }

    func testGetAnAppGroupRelatedDevices() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone"))
        ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { appGroupResult in
            guard case let .success(appGroup) = appGroupResult else {
                return XCTFail("Expected .success, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.devices.relatedIds, [121])

            appGroup.devices.getAll(completion: { devicesResult in
                guard case let .success(devices) = devicesResult else {
                    return XCTFail("Expected .success, got \(devicesResult)")
                }
                XCTAssertEqual(devices.map({ $0.id }), [121])
                XCTAssertEqual(devices[0].name, "Mike's iPhone")
            })
        }
    }
}
