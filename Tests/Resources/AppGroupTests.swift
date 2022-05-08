//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class AppGroupTests: XCTestCase {
    func testGetAllAppGroups() async throws {
        let json = loadFixture("AppGroups")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let appGroups = try await AppGroup.all.collect()
        XCTAssertEqual(appGroups.count, 2)
    }

    func testGetAnAppGroup() async throws {
        let json = loadFixture("AppGroup_ProductivityApps")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let appGroup = try await AppGroup.get(id: 38)
        XCTAssertEqual(appGroup.name, "Productivity Apps")
    }

    func testErrorWhileFetchingRelatedToMany() async throws {
        let sessionMock = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello")),
            "/api/v1/apps/67": Response(data: Data(), code: 404)
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let appGroup = try await AppGroup.get(id: 38)
        XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

        await XCTAssertAsyncThrowsError({
            try await appGroup.apps.collect()
        }) { error in
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
        }
    }

    func testFetchingRelatedToManyAsynchronouslyWithDelay() async throws {
        let sessionMock = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello"), delay: .milliseconds(50)),
            "/api/v1/apps/67": Response(data: loadFixture("App_Evernote"), delay: .milliseconds(10))
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let expectedIDs = [63, 67]
        let expectedNames = ["Trello", "Evernote"]

        let appGroup = try await AppGroup.get(id: 38)
        XCTAssertEqual(appGroup.apps.relatedIds, expectedIDs)

        var i = 0
        for try await app in appGroup.apps {
            XCTAssertEqual(app.id, expectedIDs[i])
            XCTAssertEqual(app.name, expectedNames[i])
            i += 1
        }
    }

    func testGetAnAppGroupRelatedApps() async throws {
        let sessionMock = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello")),
            "/api/v1/apps/67": Response(data: loadFixture("App_Evernote"))
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let expectedIDs = [63, 67]
        let expectedNames = ["Trello", "Evernote"]

        let appGroup = try await AppGroup.get(id: 38)
        XCTAssertEqual(appGroup.apps.relatedIds, expectedIDs)

        var i = 0
        for try await app in appGroup.apps {
            XCTAssertEqual(app.id, expectedIDs[i])
            XCTAssertEqual(app.name, expectedNames[i])
            i += 1
        }
    }

    func testGetAnAppGroupRelatedDeviceGroups() async throws {
        let sessionMock = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/device_groups/37": Response(data: loadFixture("DeviceGroup_Interns")),
            "/api/v1/device_groups/38": Response(data: loadFixture("DeviceGroup_Executives"))
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let expectedIDs = [37, 38]
        let expectedNames = ["Interns", "Executives"]

        let appGroup = try await AppGroup.get(id: 38)
        XCTAssertEqual(appGroup.deviceGroups.relatedIds, expectedIDs)

        var i = 0
        for try await deviceGroup in appGroup.deviceGroups {
            XCTAssertEqual(deviceGroup.id, expectedIDs[i])
            XCTAssertEqual(deviceGroup.name, expectedNames[i])
            i += 1
        }
    }

    func testGetAnAppGroupRelatedDevices() async throws {
        let sessionMock = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone"))
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let expectedIDs = [121]
        let expectedNames = ["Mike's iPhone"]

        let appGroup = try await AppGroup.get(id: 38)
        XCTAssertEqual(appGroup.devices.relatedIds, expectedIDs)

        var i = 0
        for try await device in appGroup.devices {
            XCTAssertEqual(device.id, expectedIDs[i])
            XCTAssertEqual(device.name, expectedNames[i])
            i += 1
        }
    }

    func testGetAnAppGroupRelatedDeviceAtPosition() async throws {
        let sessionMock = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone"))
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let expectedID = 121
        let expectedName = "Mike's iPhone"

        let appGroup = try await AppGroup.get(id: 38)
        XCTAssertEqual(appGroup.devices.relatedIds.count, 1)
        XCTAssertEqual(appGroup.devices.relatedIds, [expectedID])

        let device = try await appGroup.devices[0]
        XCTAssertEqual(device.id, expectedID)
        XCTAssertEqual(device.name, expectedName)
    }

    func testGetAnAppGroupRelatedDeviceById() async throws {
        let sessionMock = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone"))
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let expectedID = 121
        let expectedName = "Mike's iPhone"

        let appGroup = try await AppGroup.get(id: 38)
        XCTAssertEqual(appGroup.devices.relatedIds.count, 1)
        XCTAssertEqual(appGroup.devices.relatedIds, [expectedID])

        let device = try await appGroup.devices[id: 121]
        XCTAssertEqual(device.id, expectedID)
        XCTAssertEqual(device.name, expectedName)
    }
}
