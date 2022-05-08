//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

////
////  Copyright 2021 Guillaume Algis.
////  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
////
//
// @testable import SimpleMDM
// import XCTest
//
// internal class ResourcesTests: XCTestCase {
//    func testUniqueResourceEndpointIsSingular() async throws {
//        XCTAssertEqual(Account.endpointName, "account")
//    }
//
//    func testNonUniqueResourceEndpointIsPlural() async throws {
//        XCTAssertEqual(Device.endpointName, "devices")
//    }
//
//    func testEmptyJSONResponse() async throws {
//        let json = "{}".data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        UniqueResourceMock.get() { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .error, got \(result)")
//            }
//            guard let decodingError = error as? DecodingError else {
//                return XCTFail("Expected error to be a DecodingError, got \(error)")
//            }
//            guard case let .keyNotFound(codingKey, _) = decodingError else {
//                return XCTFail("Expected .keyNotFound, got \(decodingError)")
//            }
//            XCTAssertEqual(codingKey.stringValue, "data")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testMalformedJSONResponse() async throws {
//        let json = """
//          {
//            "attributes": {
//              "name": "MyCompany",
//              "apple_store_country_code": "US"
//            }
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        UniqueResourceMock.get() { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .error, got \(result)")
//            }
//            guard let decodingError = error as? DecodingError else {
//                return XCTFail("Expected error to be a DecodingError, got \(error)")
//            }
//            guard case let .keyNotFound(codingKey, _) = decodingError else {
//                return XCTFail("Expected .keyNotFound, got \(decodingError)")
//            }
//            XCTAssertEqual(codingKey.stringValue, "data")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testGetUnexistentResource() async throws {
//        let json = """
//          {
//            "errors": [
//              {
//                "title": "object not found"
//              }
//            ]
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 404)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        ResourceMock.get(id: 0) { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .error, got \(result)")
//            }
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//            }
//            XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
//            XCTAssertTrue(simpleMDMError.localizedDescription.contains("does not exist"))
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testUnexpectedServerResponseCodeWithNoErrorDescription() async throws {
//        let errorCode = 500
//        let json = """
//          {
//            "errors": []
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: errorCode)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        UniqueResourceMock.get() { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .error, got \(result)")
//            }
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//            }
//            XCTAssertEqual(simpleMDMError, SimpleMDMError.unknown(httpCode: errorCode))
//            XCTAssertTrue(simpleMDMError.localizedDescription.contains(String(errorCode)))
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testUnexpectedServerResponseCodeWithMalformedBody() async throws {
//        let errorCode = 500
//        let json = """
//          {
//            "data": [],
//            "has_more": false
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: errorCode)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        UniqueResourceMock.get() { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .error, got \(result)")
//            }
//            guard let decodingError = error as? DecodingError else {
//                return XCTFail("Expected error to be a DecodingError, got \(error)")
//            }
//            guard case let .keyNotFound(codingKey, _) = decodingError else {
//                return XCTFail("Expected .keyNotFound, got \(decodingError)")
//            }
//            XCTAssertEqual(codingKey.stringValue, "errors")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testUnexpectedServerError() async throws {
//        let errorCode = 500
//        let errorMessage = "Internal Server Error"
//        let json = """
//          {
//            "errors": [
//              {
//                "title": "\(errorMessage)"
//              }
//            ]
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: errorCode)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        UniqueResourceMock.get() { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .error, got \(result)")
//            }
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//            }
//            XCTAssertEqual(simpleMDMError, SimpleMDMError.generic(httpCode: errorCode, description: errorMessage))
//            XCTAssertTrue(simpleMDMError.localizedDescription.contains(errorMessage))
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testGetEmptyResourcesList() async throws {
//        let json = """
//          {
//            "data": [],
//            "has_more": false
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        ResourceMock.getAll() { result in
//            guard case let .fulfilled(resources) = result else {
//                return XCTFail("Expected .fulfilled, got \(result)")
//            }
//            XCTAssertEqual(resources.count, 0)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testGetResourcesListWithMissingHasMoreAttribute() async throws {
//        let json = """
//          {
//            "data": []
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        ResourceMock.getAll() { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .rejected, got \(result)")
//            }
//            guard let decodingError = error as? DecodingError else {
//                return XCTFail("Expected error to be a DecodingError, got \(error)")
//            }
//            guard case let .keyNotFound(codingKey, _) = decodingError else {
//                return XCTFail("Expected .keyNotFound, got \(decodingError)")
//            }
//            XCTAssertEqual(codingKey.stringValue, "hasMore")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testInvalidDateFormatISO8601() async throws {
//        let json = """
//          {
//            "data": {
//              "type": "resource_with_date_mock",
//              "id": 1,
//              "attributes": {
//                "date": "2019-05-22T15:12:23+00:00"
//              }
//            }
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        ResourceWithDateMock.get(id: 1) { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .error, got \(result)")
//            }
//            guard let decodingError = error as? DecodingError else {
//                return XCTFail("Expected error to be a DecodingError, got \(error)")
//            }
//            guard case let .dataCorrupted(context) = decodingError else {
//                return XCTFail("Expected .dataCorrupted, got \(decodingError)")
//            }
//            XCTAssertTrue(context.debugDescription.contains("Date is not of expected RFC3339 format"))
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testInvalidDateOldSimpleMDMFormat() async throws {
//        let json = """
//          {
//            "data": {
//              "type": "resource_with_date_mock",
//              "id": 1,
//              "attributes": {
//                "date": "2019-05-22 15:12:23 Z"
//              }
//            }
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        ResourceWithDateMock.get(id: 1) { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .error, got \(result)")
//            }
//            guard let decodingError = error as? DecodingError else {
//                return XCTFail("Expected error to be a DecodingError, got \(error)")
//            }
//            guard case let .dataCorrupted(context) = decodingError else {
//                return XCTFail("Expected .dataCorrupted, got \(decodingError)")
//            }
//            XCTAssertTrue(context.debugDescription.contains("Date is not of expected RFC3339 format"))
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testInvalidResourceType() async throws {
//        let json = """
//          {
//            "data": {
//              "type": "nonexistant_type",
//              "attributes": {
//                "name": "MyCompany",
//                "apple_store_country_code": "US"
//              }
//            }
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        UniqueResourceMock.get() { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .error, got \(result)")
//            }
//            guard let decodingError = error as? DecodingError else {
//                return XCTFail("Expected error to be a DecodingError, got \(error)")
//            }
//            guard case let .dataCorrupted(context) = decodingError else {
//                return XCTFail("Expected .dataCorrupted, got \(decodingError)")
//            }
//            XCTAssertEqual(context.debugDescription, "Expected type of resource to be \"unique_resource_mock\" but got \"nonexistant_type\"")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testFetchResourceWithUnexpectedId() async throws {
//        let json = """
//          {
//            "data": {
//              "attributes": {
//              },
//              "id": 67,
//              "type": "resource_mock"
//            }
//          }
//        """.data(using: .utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        ResourceMock.get(id: 63) { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .error, got \(result)")
//            }
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//            }
//            XCTAssertEqual(simpleMDMError, SimpleMDMError.unexpectedResourceId)
//            XCTAssertTrue(simpleMDMError.localizedDescription.contains("unexpected id"))
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
// }
