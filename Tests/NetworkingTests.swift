//
//  NetworkTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

@testable import SimpleMDM
import XCTest

class NetworkingTests: XCTestCase {
    func testReturnUnknownErrorIfRequestFails() {
        let session = URLSessionMock(data: nil)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.unknown)
        }
    }

    func testUnknownErrorHasHumanReadableDescription() {
        let session = URLSessionMock(data: nil)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError.localizedDescription, "Unknown network error")
        }
    }

    func testReturnNoHTTPResponseIfNoResponseReturned() {
        let session = URLSessionMock()
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.noHTTPResponse)
        }
    }

    func testNoHTTPResponseErrorHasHumanReadableDescription() {
        let session = URLSessionMock()
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError.localizedDescription, "Did not receive a HTTP response")
        }
    }

    func testReturnErrorForHTMLMimeType() {
        let mimeType = "text/html"
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.unexpectedMimeType(mimeType))
        }
    }

    func testReturnErrorForNullMimeType() {
        let mimeType: String? = nil
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.unexpectedMimeType(mimeType))
        }
    }

    func testInvalidMimeTypeErrorHasHumanReadableDescription() {
        let mimeType = "text/html"
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertTrue(networkError.localizedDescription.contains(mimeType))
        }
    }

    func testNullMimeTypeErrorHasHumanReadableDescription() {
        let mimeType: String? = nil
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networkingService = NetworkingService(urlSession: session)
        networkingService.APIKey = "AVeryRandomTestAPIKey"

        networkingService.getDataForAllResources(ofType: Account.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertTrue(networkError.localizedDescription.contains("null"))
        }
    }
}
