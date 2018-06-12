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
            XCTAssertEqual(error, APIError.unknown(code: errorCode))
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
            XCTAssertEqual(error, APIError.generic(code: errorCode, description: errorMessage))
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
            let apps = result.value!
            XCTAssertEqual(apps.count, 2)
        }
    }

    func testGetAnAppGroup() {
        let json = loadFixture("AppGroup_ProductivityApps")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        AppGroup.get(id: 38) { (result) in
            let app = result.value!
            XCTAssertEqual(app.name, "Productivity Apps")
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
}
