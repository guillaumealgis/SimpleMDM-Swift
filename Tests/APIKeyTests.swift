//
//  APIKeyTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import XCTest
@testable import SimpleMDM

class APIKeyTests: XCTestCase {

    func testNotSettingAPIKeyReturnsError() {
        let session = URLSessionMock()
        let networkController = NetworkController(urlSession: session)

        networkController.getUniqueResource(type: Account.self) { (result) in
            XCTAssertEqual(result.error! as! APIKeyError, APIKeyError.notSet)
        }
    }

    func testAPIKeyNotSetErrorHasHumanReadableDescription() {
        let session = URLSessionMock()
        let networkController = NetworkController(urlSession: session)

        networkController.getUniqueResource(type: Account.self) { (result) in
            let error = result.error! as! LocalizedError
            XCTAssertTrue(error.localizedDescription.contains("API key was not set"))
        }
    }

    func test401ResponseReturnsInvalidAPIKeyError() {
        let session = URLSessionMock(responseCode: 401)
        let networkController = NetworkController(urlSession: session)
        networkController.APIKey = "AVeryRandomTestAPIKey"

        networkController.getUniqueResource(type: Account.self) { (result) in
            XCTAssertEqual(result.error! as! APIKeyError, APIKeyError.invalid)
        }
    }

    func testInvalidAPIKeyErrorHasHumanReadableDescription() {
        let session = URLSessionMock(responseCode: 401)
        let networkController = NetworkController(urlSession: session)
        networkController.APIKey = "AVeryRandomTestAPIKey"

        networkController.getUniqueResource(type: Account.self) { (result) in
            let error = result.error! as! LocalizedError
            XCTAssertTrue(error.localizedDescription.contains("server rejected the API key"))
        }
    }

}
