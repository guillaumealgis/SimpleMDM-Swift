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

    func testSettingAPIKeyViaSingleton() {
        let APIKey = "AVeryRandomTestAPIKey"
        SimpleMDM.APIKey = APIKey

        XCTAssertEqual(SimpleMDM.APIKey, APIKey)
        XCTAssertEqual(SimpleMDM.shared.networkingService.APIKey, APIKey)
    }

    func testNotSettingAPIKeyReturnsError() {
        let session = URLSessionMock()
        let networkingService = NetworkingService(urlSession: session)

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let apiKeyError = error as? APIKeyError else {
                return XCTFail("Expected error to be an APIKeyError, got \(error)")
            }
            XCTAssertEqual(apiKeyError, APIKeyError.notSet)
        }
    }

    func testAPIKeyNotSetErrorHasHumanReadableDescription() {
        let session = URLSessionMock()
        let networkingService = NetworkingService(urlSession: session)

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let apiKeyError = error as? APIKeyError else {
                return XCTFail("Expected error to be an APIKeyError, got \(error)")
            }
            XCTAssertTrue(apiKeyError.localizedDescription.contains("API key was not set"))
        }
    }

    func test401ResponseReturnsInvalidAPIKeyError() {
        let session = URLSessionMock(responseCode: 401)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let apiKeyError = error as? APIKeyError else {
                return XCTFail("Expected error to be an APIKeyError, got \(error)")
            }
            XCTAssertEqual(apiKeyError, APIKeyError.invalid)
        }
    }

    func testInvalidAPIKeyErrorHasHumanReadableDescription() {
        let session = URLSessionMock(responseCode: 401)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let apiKeyError = error as? APIKeyError else {
                return XCTFail("Expected error to be an APIKeyError, got \(error)")
            }
            XCTAssertTrue(apiKeyError.localizedDescription.contains("server rejected the API key"))
        }
    }

}
