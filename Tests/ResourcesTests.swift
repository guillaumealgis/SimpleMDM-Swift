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
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            XCTAssertTrue(error is DecodingError)
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
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            XCTAssertTrue(error is DecodingError)
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
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let apiError = error as? APIError else {
                return XCTFail("Expected error to be an APIError, got \(error)")
            }
            XCTAssertEqual(apiError, APIError.doesNotExist)
            XCTAssertTrue(apiError.localizedDescription.contains("does not exist"))
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
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let apiError = error as? APIError else {
                return XCTFail("Expected error to be an APIError, got \(error)")
            }
            XCTAssertEqual(apiError, APIError.unknown(httpCode: errorCode))
            XCTAssertTrue(apiError.localizedDescription.contains(String(errorCode)))
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
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            XCTAssertTrue(error is DecodingError)
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
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let apiError = error as? APIError else {
                return XCTFail("Expected error to be an APIError, got \(error)")
            }
            XCTAssertEqual(apiError, APIError.generic(httpCode: errorCode, description: errorMessage))
            XCTAssertTrue(apiError.localizedDescription.contains(errorMessage))
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
            guard case let .success(resources) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(resources.count, 0)
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
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            XCTAssertTrue(error is DecodingError)
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
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testFetchResourceWithUnexpectedId() {
        let json = loadFixture("App_GoogleCalendar")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        App.get(id: 63) { (result) in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let apiError = error as? APIError else {
                return XCTFail("Expected error to be an APIError, got \(error)")
            }
            XCTAssertEqual(apiError, APIError.unexpectedResourceId)
            XCTAssertTrue(apiError.localizedDescription.contains("unexpected id"))
        }
    }

    func testGetAccount() {
        let json = loadFixture("Account")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Account.get { (result) in
            guard case let .success(account) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(account.name, "MyCompany")
            XCTAssertEqual(account.appleStoreCountryCode, "US")
        }
    }

    func testGetAllApps() {
        let json = loadFixture("Apps")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        App.getAll { (result) in
            guard case let .success(apps) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(apps.count, 5)
        }
    }

    func testGetAnApp() {
        let json = loadFixture("App_SimpleMDM")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        App.get(id: 17635) { (result) in
            guard case let .success(app) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(app.bundleIdentifier, "com.unwiredrev.DeviceLink.public")
        }
    }

    func testGetAllAppGroups() {
        let json = loadFixture("AppGroups")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        AppGroup.getAll { (result) in
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

        AppGroup.get(id: 38) { (result) in
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
            "/api/v1/apps/67": Response(data: Data(), code: 404),
            ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (appGroupResult) in
            guard case let .success(appGroup) = appGroupResult else {
                return XCTFail("Expected .success, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(completion: { (appsResult) in
                guard case let .failure(error) = appsResult else {
                    return XCTFail("Expected .failure, got \(appsResult)")
                }
                guard let apiError = error as? APIError else {
                    return XCTFail("Expected error to be an APIError, got \(error)")
                }
                XCTAssertEqual(apiError, APIError.doesNotExist)
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
            guard case let .success(appGroup) = appGroupResult else {
                return XCTFail("Expected .success, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(completion: { (appsResult) in
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
            "/api/v1/apps/67": Response(data: loadFixture("App_Evernote")),
            ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (appGroupResult) in
            guard case let .success(appGroup) = appGroupResult else {
                return XCTFail("Expected .success, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.apps.relatedIds, [63, 67])

            appGroup.apps.getAll(completion: { (appsResult) in
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
            "/api/v1/device_groups/38": Response(data: loadFixture("DeviceGroup_Executives")),
            ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (appGroupResult) in
            guard case let .success(appGroup) = appGroupResult else {
                return XCTFail("Expected .success, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.deviceGroups.relatedIds, [37, 38])

            appGroup.deviceGroups.getAll(completion: { (deviceGroupsResult) in
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
            "/api/v1/devices/121": Response(data: loadFixture("Device_MikesiPhone")),
            ])
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (appGroupResult) in
            guard case let .success(appGroup) = appGroupResult else {
                return XCTFail("Expected .success, got \(appGroupResult)")
            }
            XCTAssertEqual(appGroup.devices.relatedIds, [121])

            appGroup.devices.getAll(completion: { (devicesResult) in
                guard case let .success(devices) = devicesResult else {
                    return XCTFail("Expected .success, got \(devicesResult)")
                }
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
            guard case let .success(customAttributes) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(customAttributes.count, 2)
        }
    }

    func testGetACustomAttribute() {
        let json = loadFixture("CustomAttribute_EmailAddress")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomAttribute.get(id: "email_address") { (result) in
            guard case let .success(customAttribute) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(customAttribute.name, "email_address")
        }
    }

    func testGetAllCustomConfigurationProfiles() {
        let json = loadFixture("CustomConfigurationProfiles")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomConfigurationProfile.getAll { (result) in
            guard case let .success(customAttributes) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(customAttributes.count, 3)
        }
    }

    func testGetACustomConfigurationProfile() {
        let json = loadFixture("CustomConfigurationProfile_MunkiConfiguration")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomConfigurationProfile.get(id: 293814) { (result) in
            guard case let .success(customConfigurationProfile) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(customConfigurationProfile.name, "Munki Configuration")
        }
    }

    func testGetACustomConfigurationProfileRelatedDeviceGroups() {
        let session = URLSessionMock(routes: [
            "/api/v1/custom_configuration_profiles/293814": Response(data: loadFixture("CustomConfigurationProfile_MunkiConfiguration")),
            "/api/v1/device_groups/38": Response(data: loadFixture("DeviceGroup_Executives")),
            ])
        SimpleMDM.useSessionMock(session)

        CustomConfigurationProfile.get(id: 293814) { (ccpResult) in
            guard case let .success(customConfigurationProfile) = ccpResult else {
                return XCTFail("Expected .success, got \(ccpResult)")
            }
            XCTAssertEqual(customConfigurationProfile.deviceGroups.relatedIds, [38])

            customConfigurationProfile.deviceGroups.getAll(completion: { (deviceGroupsResult) in
                guard case let .success(deviceGroups) = deviceGroupsResult else {
                    return XCTFail("Expected .success, got \(deviceGroupsResult)")
                }
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

        Device.get(id: 121) { (result) in
            guard case let .success(device) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
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
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }
            XCTAssertEqual(device.deviceGroup.relatedId, 37)

            device.deviceGroup.get(completion: { (deviceGroupResult) in
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
            "/api/v1/device_groups/37": Response(data: Data(), code: 404),
            ])
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { (deviceResult) in
            guard case let .success(device) = deviceResult else {
                return XCTFail("Expected .success, got \(deviceResult)")
            }
            XCTAssertEqual(device.deviceGroup.relatedId, 37)

            device.deviceGroup.get(completion: { (deviceGroupResult) in
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

    func testGetAllDeviceGroups() {
        let json = loadFixture("DeviceGroups")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        DeviceGroup.getAll { (result) in
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

        DeviceGroup.get(id: 38) { (result) in
            guard case let .success(device) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(device.name, "Executives")
        }
    }

    func testGetAnInstalledApp() {
        let json = loadFixture("InstalledApp_Dropbox")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        InstalledApp.get(id: 10446659) { (result) in
            guard case let .success(installedApp) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(installedApp.name, "Dropbox")
        }
    }

    func testGetPushCertificate() {
        let json = loadFixture("PushCertificate")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        PushCertificate.get { (result) in
            guard case let .success(pushCertificate) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(pushCertificate.appleId, "devops@example.org")
        }
    }
}
