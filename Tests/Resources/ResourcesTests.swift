//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

// swiftlint:disable:next type_body_length
internal class ResourcesTests: XCTestCase {
    func testUniqueResourceEndpointIsSingular() {
        XCTAssertEqual(Account.endpointName, "account")
    }

    func testNonUniqueResourceEndpointIsPlural() {
        XCTAssertEqual(Device.endpointName, "devices")
    }

    func testEmptyJSONResponse() {
        let json = "{}".data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Account.get(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let decodingError = error as? DecodingError else {
                return XCTFail("Expected error to be a DecodingError, got \(error)")
            }
            guard case let .keyNotFound(codingKey, _) = decodingError else {
                return XCTFail("Expected .keyNotFound, got \(decodingError)")
            }
            XCTAssertEqual(codingKey.stringValue, "data")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
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
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Account.get(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let decodingError = error as? DecodingError else {
                return XCTFail("Expected error to be a DecodingError, got \(error)")
            }
            guard case let .keyNotFound(codingKey, _) = decodingError else {
                return XCTFail("Expected .keyNotFound, got \(decodingError)")
            }
            XCTAssertEqual(codingKey.stringValue, "data")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
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
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.get(s.networking, id: 0) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
            XCTAssertTrue(simpleMDMError.localizedDescription.contains("does not exist"))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testUnexpectedServerResponseCodeWithNoErrorDescription() {
        let errorCode = 500
        let json = """
          {
            "errors": []
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: errorCode)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Account.get(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.unknown(httpCode: errorCode))
            XCTAssertTrue(simpleMDMError.localizedDescription.contains(String(errorCode)))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testUnexpectedServerResponseCodeWithMalformedBody() {
        let errorCode = 500
        let json = """
          {
            "data": [],
            "has_more": false
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: errorCode)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Account.get(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let decodingError = error as? DecodingError else {
                return XCTFail("Expected error to be a DecodingError, got \(error)")
            }
            guard case let .keyNotFound(codingKey, _) = decodingError else {
                return XCTFail("Expected .keyNotFound, got \(decodingError)")
            }
            XCTAssertEqual(codingKey.stringValue, "errors")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
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
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Account.get(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.generic(httpCode: errorCode, description: errorMessage))
            XCTAssertTrue(simpleMDMError.localizedDescription.contains(errorMessage))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetEmptyResourcesList() {
        let json = """
          {
            "data": [],
            "has_more": false
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.getAll(s.networking) { result in
            guard case let .success(resources) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(resources.count, 0)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetResourcesListWithMissingHasMoreAttribute() {
        let json = """
          {
            "data": []
          }
        """.data(using: .utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Device.getAll(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let decodingError = error as? DecodingError else {
                return XCTFail("Expected error to be a DecodingError, got \(error)")
            }
            guard case let .keyNotFound(codingKey, _) = decodingError else {
                return XCTFail("Expected .keyNotFound, got \(decodingError)")
            }
            XCTAssertEqual(codingKey.stringValue, "hasMore")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
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
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        PushCertificate.get(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let decodingError = error as? DecodingError else {
                return XCTFail("Expected error to be a DecodingError, got \(error)")
            }
            guard case let .dataCorrupted(context) = decodingError else {
                return XCTFail("Expected .dataCorrupted, got \(decodingError)")
            }
            XCTAssertEqual(context.debugDescription, "Date string does not match any expected format")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
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
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Account.get(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let decodingError = error as? DecodingError else {
                return XCTFail("Expected error to be a DecodingError, got \(error)")
            }
            guard case let .dataCorrupted(context) = decodingError else {
                return XCTFail("Expected .dataCorrupted, got \(decodingError)")
            }
            XCTAssertEqual(context.debugDescription, "Expected type of resource to be \"account\" but got \"nonexistant_type\"")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testFetchResourceWithUnexpectedId() {
        let json = loadFixture("App_GoogleCalendar")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        App.get(s.networking, id: 63) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.unexpectedResourceId)
            XCTAssertTrue(simpleMDMError.localizedDescription.contains("unexpected id"))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
