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
        let json = loadFixture("Device_121")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        Device.get(id: 121) { (result) in
            let device = result.value!
            XCTAssertEqual(device.name, "Mike's iPhone")
        }
    }

    func testGetUnexistentDevice() {
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

        Device.getAll { (result) in
            XCTAssertEqual(result.error! as! APIError, APIError.doesNotExist)
        }
    }

}
