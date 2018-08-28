//
//  ResourcesTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import XCTest
@testable import SimpleMDM

class ResourcesTests: XCTestCase {

    func testUniqueResourceEndpointIsSingular() {
        XCTAssertEqual(Account.endpointName, "account")
    }

    func testNonUniqueResourceEndpointIsPlural() {
        XCTAssertEqual(Device.endpointName, "devices")
    }

    func testEmptyJSONResponse() {
        let json = "{}".data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Account.get { (result) in
            XCTAssertNoThrow(result.error! as! DecodingError)
        }
    }

    func testMalformedJSONResponse() {
        let json = """
          {
            "attributes": {
              "name": "MyCompany",
              "apple_store_country_code": "US"
            }
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Account.get { (result) in
            XCTAssertNoThrow(result.error! as! DecodingError)
        }
    }

    func testGetUnexistentResource() {
        let json = """
          {
            "errors": [
              {
                "title": "object not found"
              }
            ]
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: 404)
        SimpleMDM.useSessionMock(session)

        Device.get(id: 0) { (result) in
            let error = result.error! as! APIError
            XCTAssertEqual(error, APIError.doesNotExist)
            XCTAssertTrue(error.localizedDescription.contains("does not exist"))
        }
    }

    func testUnexpectedServerResponseCodeWithNoErrorDescription() {
        let errorCode = 500
        let json = """
          {
            "errors": []
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: errorCode)
        SimpleMDM.useSessionMock(session)

        Account.get { (result) in
            let error = result.error! as! APIError
            XCTAssertEqual(error, APIError.unknown(httpCode: errorCode))
            XCTAssertTrue(error.localizedDescription.contains(String(errorCode)))
        }
    }

    func testUnexpectedServerResponseCodeWithMalformedBody() {
        let errorCode = 500
        let json = """
          {
            "data": []
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: errorCode)
        SimpleMDM.useSessionMock(session)

        Account.get { (result) in
            XCTAssertNoThrow(result.error! as! DecodingError)
        }
    }

    func testUnexpectedServerError() {
        let errorCode = 500
        let errorMessage = "Internal Server Error"
        let json = """
          {
            "errors": [
              {
                "title": "\(errorMessage)"
              }
            ]
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: errorCode)
        SimpleMDM.useSessionMock(session)

        Account.get { (result) in
            let error = result.error! as! APIError
            XCTAssertEqual(error, APIError.generic(httpCode: errorCode, description: errorMessage))
            XCTAssertTrue(error.localizedDescription.contains(errorMessage))
        }
    }

    func testGetEmptyResourcesList() {
        let json = """
          {
            "data": []
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Device.getAll() { (result) in
            XCTAssertEqual(result.value!.count, 0)
        }
    }

    func testInvalidDateFormat() {
        let json = """
          {
            "data": {
              "type": "push_certificate",
              "attributes": {
                "apple_id": "invalid-date@example.org",
                "expires_at": "2019-05-22T15:12:23.344+00:00"
              }
            }
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        PushCertificate.get { (result) in
            XCTAssertNoThrow(result.error! as! DecodingError)
        }
    }

    func testInvalidResourceType() {
        let json = """
          {
            "data": {
              "type": "nonexistant_type",
              "attributes": {
                "name": "MyCompany",
                "apple_store_country_code": "US"
              }
            }
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Account.get { (result) in
            XCTAssertNoThrow(result.error! as! DecodingError)
        }
    }

    func testGetAccount() {
        let json = loadFixture("Account")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Account.get { (result) in
            let account = result.value!
            XCTAssertEqual(account.name, "MyCompany")
            XCTAssertEqual(account.appleStoreCountryCode, "US")
        }
    }

    func testGetAllApps() {
        let json = loadFixture("Apps")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        App.getAll { (result) in
            let apps = result.value!
            XCTAssertEqual(apps.count, 5)
        }
    }

    func testGetAnApp() {
        let json = loadFixture("App_SimpleMDM")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        App.get(id: 17635) { (result) in
            let app = result.value!
            XCTAssertEqual(app.bundleIdentifier, "com.unwiredrev.DeviceLink.public")
        }
    }

    func testGetAllAppGroups() {
        let json = loadFixture("AppGroups")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        AppGroup.getAll { (result) in
            let appGroups = result.value!
            XCTAssertEqual(appGroups.count, 2)
        }
    }

    func testGetAnAppGroup() {
        let json = loadFixture("AppGroup_ProductivityApps")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (result) in
            let appGroup = result.value!
            XCTAssertEqual(appGroup.name, "Productivity Apps")
        }
    }

    func testErrorWhileFetchingRelatedToMany() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello")),
            "/api/v1/apps/67": Response(data: Data(), code: 404),
            ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (appGroupResult) in
            let appGroup = appGroupResult.value!

            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(completion: { (appsResult) in
                let error = appsResult.error! as! APIError
                XCTAssertEqual(error, APIError.doesNotExist)
            })
        }
    }

    func testFetchingRelatedToManyAsynchronouslyWithDelay() {
        let expectation = XCTestExpectation(description: "testFetchingRelatedToManyAsynchronouslyWithDelay expectation")
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/apps/63": Response(data: loadFixture("App_Trello"), delay: .milliseconds(50)),
            "/api/v1/apps/67": Response(data: loadFixture("App_Evernote"), delay: .milliseconds(10)),
            ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (appGroupResult) in
            let appGroup = appGroupResult.value!

            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(completion: { (appsResult) in
                let apps = appsResult.value!
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
            "/api/v1/apps/67": Response(data: loadFixture("App_Evernote")),
            ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (appGroupResult) in
            let appGroup = appGroupResult.value!

            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(completion: { (appsResult) in
                let apps = appsResult.value!
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
            "/api/v1/device_groups/38": Response(data: loadFixture("DeviceGroup_Executives")),
            ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (appGroupResult) in
            let appGroup = appGroupResult.value!

            XCTAssertEqual(appGroup.deviceGroups.relatedIds, [37, 38])

            appGroup.deviceGroups.getAll(completion: { (deviceGroupsResult) in
                let deviceGroups = deviceGroupsResult.value!
                XCTAssertEqual(deviceGroups.map({ $0.id }), [37, 38])
                XCTAssertEqual(deviceGroups[0].name, "Interns")
                XCTAssertEqual(deviceGroups[1].name, "Executives")
            })
        }
    }

    func testGetAnAppGroupRelatedDevices() {
        let session = URLSessionMock(routes: [
            "/api/v1/app_groups/38": Response(data: loadFixture("AppGroup_ProductivityApps")),
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (appGroupResult) in
            let appGroup = appGroupResult.value!

            XCTAssertEqual(appGroup.devices.relatedIds, [121])

            appGroup.devices.getAll(completion: { (devicesResult) in
                let devices = devicesResult.value!
                XCTAssertEqual(devices.map({ $0.id }), [121])
                XCTAssertEqual(devices[0].name, "Mike's iPhone")
            })
        }
    }

    func testGetAllCustomAttributes() {
        let json = loadFixture("CustomAttributes")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomAttribute.getAll { (result) in
            let customAttributes = result.value!
            XCTAssertEqual(customAttributes.count, 2)
        }
    }

    func testGetACustomAttribute() {
        let json = loadFixture("CustomAttribute_EmailAddress")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomAttribute.get(id: "email_address") { (result) in
            let customAttribute = result.value!
            XCTAssertEqual(customAttribute.name, "email_address")
        }
    }

    func testGetAllCustomConfigurationProfiles() {
        let json = loadFixture("CustomConfigurationProfiles")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomConfigurationProfile.getAll { (result) in
            let customAttributes = result.value!
            XCTAssertEqual(customAttributes.count, 3)
        }
    }

    func testGetACustomConfigurationProfile() {
        let json = loadFixture("CustomConfigurationProfile_MunkiConfiguration")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomConfigurationProfile.get(id: 293814) { (result) in
            let customAttribute = result.value!
            XCTAssertEqual(customAttribute.name, "Munki Configuration")
        }
    }

    func testGetACustomConfigurationProfileRelatedDeviceGroups() {
        let session = URLSessionMock(routes: [
            "/api/v1/custom_configuration_profiles/293814": Response(data: loadFixture("CustomConfigurationProfile_MunkiConfiguration")),
            "/api/v1/device_groups/38": Response(data: loadFixture("DeviceGroup_Executives")),
            ])
        SimpleMDM.useSessionMock(session)

        CustomConfigurationProfile.get(id: 293814) { (ccpResult) in
            let customConfigurationProfile = ccpResult.value!

            XCTAssertEqual(customConfigurationProfile.deviceGroups.relatedIds, [38])

            customConfigurationProfile.deviceGroups.getAll(completion: { (deviceGroupsResult) in
                let deviceGroups = deviceGroupsResult.value!
                XCTAssertEqual(deviceGroups.map({ $0.id }), [38])
                XCTAssertEqual(deviceGroups[0].name, "Executives")
            })
        }
    }

    func testGetAllDevices() {
        let json = loadFixture("Devices")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Device.getAll { (result) in
            let devices = result.value!
            XCTAssertEqual(devices.count, 2)
        }
    }

    func testGetADevice() {
        let json = loadFixture("Device_MikesiPhone")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { (result) in
            let device = result.value!
            XCTAssertEqual(device.name, "Mike's iPhone")
        }
    }

    func testGetADeviceRelatedDeviceGroup() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/device_groups/37": Response(data: loadFixture("DeviceGroup_Interns")),
            ])
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { (deviceResult) in
            let device = deviceResult.value!

            XCTAssertEqual(device.deviceGroup.relatedId, 37)

            device.deviceGroup.get(completion: { (deviceGroupResult) in
                let deviceGroup = deviceGroupResult.value!
                XCTAssertEqual(deviceGroup.name, "Interns")
            })
        }
    }

    func testErrorWhileFetchingRelatedToOne() {
        let session = URLSessionMock(routes: [
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            "/api/v1/device_groups/37": Response(data: Data(), code: 404),
            ])
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { (deviceResult) in
            let device = deviceResult.value!

            XCTAssertEqual(device.deviceGroup.relatedId, 37)

            device.deviceGroup.get(completion: { (deviceGroupResult) in
                let error = deviceGroupResult.error! as! APIError
                XCTAssertEqual(error, APIError.doesNotExist)
            })
        }
    }

    func testGetAllDeviceGroups() {
        let json = loadFixture("DeviceGroups")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        DeviceGroup.getAll { (result) in
            let devices = result.value!
            XCTAssertEqual(devices.count, 2)
        }
    }

    func testGetADeviceGroup() {
        let json = loadFixture("DeviceGroup_Executives")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        DeviceGroup.get(id: 38) { (result) in
            let device = result.value!
            XCTAssertEqual(device.name, "Executives")
        }
    }

    func testGetAnInstalledApp() {
        let json = loadFixture("InstalledApp_Dropbox")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        InstalledApp.get(id: 10446659) { (result) in
            let installedApp = result.value!
            XCTAssertEqual(installedApp.name, "Dropbox")
        }
    }

    func testGetPushCertificate() {
        let json = loadFixture("PushCertificate")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        PushCertificate.get { (result) in
            let pushCertificate = result.value!
            XCTAssertEqual(pushCertificate.appleId, "devops@example.org")
        }
    }
}
