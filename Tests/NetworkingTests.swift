//
//  NetworkTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import XCTest
@testable import SimpleMDM

class NetworkingTests: XCTestCase {

    func testReturnUnknownErrorIfRequestFails() {
        let session = URLSessionMock(data: nil)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            XCTAssertEqual(result.error! as! NetworkError, NetworkError.unknown)
        }
    }

    func testUnknownErrorHasHumanReadableDescription() {
        let session = URLSessionMock(data: nil)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            let error = result.error! as! LocalizedError
            XCTAssertEqual(error.localizedDescription, "Unknown network error")
        }
    }

    func testReturnNoHTTPResponseIfNoResponseReturned() {
        let session = URLSessionMock()
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            XCTAssertEqual(result.error! as! NetworkError, NetworkError.noHTTPResponse)
        }
    }

    func testNoHTTPResponseErrorHasHumanReadableDescription() {
        let session = URLSessionMock()
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            let error = result.error! as! LocalizedError
            XCTAssertEqual(error.localizedDescription, "Did not receive a HTTP response")
        }
    }

    func testReturnErrorForHTMLMimeType() {
        let mimeType = "text/html"
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            XCTAssertEqual(result.error! as! NetworkError, NetworkError.unexpectedMimeType(mimeType))
        }
    }

    func testReturnErrorForNullMimeType() {
        let mimeType: String? = nil
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            XCTAssertEqual(result.error! as! NetworkError, NetworkError.unexpectedMimeType(mimeType))
        }
    }

    func testInvalidMimeTypeErrorHasHumanReadableDescription() {
        let mimeType = "text/html"
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            let error = result.error! as! LocalizedError
            XCTAssertTrue(error.localizedDescription.contains(mimeType))
        }
    }

    func testNullMimeTypeErrorHasHumanReadableDescription() {
        let mimeType: String? = nil
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { (result) in
            let error = result.error! as! LocalizedError
            XCTAssertTrue(error.localizedDescription.contains("null"))
        }
    }

}
