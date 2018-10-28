//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

/// This class tests weither the exposed API using the SimpleMDM singleton calls to the right Networking instance.
/// We do this by using a networking mock which returns a nonsensical HTTP code, and check in the callback we got
/// this code as expected.
internal class SimpleMDMSingletonTests: XCTestCase {
    override static func setUp() {
        let session = URLSessionMock(responseCode: 999)
        let networking = Networking(urlSession: session)
        networking.APIKey = "AGlobalAndRandomAPIKey"
        SimpleMDM.shared.networking = networking
    }

    func testUniqueResourceGetViaSingleton() {
        let expectation = self.expectation(description: "Callback called")

        UniqueResourceMock.get { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
            }
            guard case let .unknown(httpCode) = simpleMDMError else {
                return XCTFail("Expected .unknown, got \(simpleMDMError)")
            }
            XCTAssertEqual(httpCode, 999)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testResourceGetAllViaSingleton() {
        let expectation = self.expectation(description: "Callback called")

        ResourceMock.getAll { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
            }
            guard case let .unknown(httpCode) = simpleMDMError else {
                return XCTFail("Expected .unknown, got \(simpleMDMError)")
            }
            XCTAssertEqual(httpCode, 999)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testResourceGetByIdViaSingleton() {
        let expectation = self.expectation(description: "Callback called")

        ResourceMock.get(id: 42) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
            }
            guard case let .unknown(httpCode) = simpleMDMError else {
                return XCTFail("Expected .unknown, got \(simpleMDMError)")
            }
            XCTAssertEqual(httpCode, 999)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testResourceGetRelatedToOneViaSingleton() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        ResourceWithRelationsMock.get(s.networking, id: 42) { result in
            guard case let .success(resource) = result else {
                return XCTFail("Expected .success, got \(result)")
            }

            resource.toOne.get { relationResult in
                guard case let .failure(error) = relationResult else {
                    return XCTFail("Expected .error, got \(relationResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
                }
                guard case let .unknown(httpCode) = simpleMDMError else {
                    return XCTFail("Expected .unknown, got \(simpleMDMError)")
                }
                XCTAssertEqual(httpCode, 999)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testResourceGetAllRelatedToManyViaSingleton() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        ResourceWithRelationsMock.get(s.networking, id: 42) { result in
            guard case let .success(resource) = result else {
                return XCTFail("Expected .success, got \(result)")
            }

            resource.toMany.getAll { relationResult in
                guard case let .failure(error) = relationResult else {
                    return XCTFail("Expected .error, got \(relationResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
                }
                guard case let .unknown(httpCode) = simpleMDMError else {
                    return XCTFail("Expected .unknown, got \(simpleMDMError)")
                }
                XCTAssertEqual(httpCode, 999)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testResourceGetRelatedToManyAtIndexViaSingleton() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        ResourceWithRelationsMock.get(s.networking, id: 42) { result in
            guard case let .success(resource) = result else {
                return XCTFail("Expected .success, got \(result)")
            }

            resource.toMany.get(at: 0) { relationResult in
                guard case let .failure(error) = relationResult else {
                    return XCTFail("Expected .error, got \(relationResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
                }
                guard case let .unknown(httpCode) = simpleMDMError else {
                    return XCTFail("Expected .unknown, got \(simpleMDMError)")
                }
                XCTAssertEqual(httpCode, 999)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testResourceGetRelatedToManyByIdViaSingleton() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        ResourceWithRelationsMock.get(s.networking, id: 42) { result in
            guard case let .success(resource) = result else {
                return XCTFail("Expected .success, got \(result)")
            }

            resource.toMany.get(id: 0) { relationResult in
                guard case let .failure(error) = relationResult else {
                    return XCTFail("Expected .error, got \(relationResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
                }
                guard case let .unknown(httpCode) = simpleMDMError else {
                    return XCTFail("Expected .unknown, got \(simpleMDMError)")
                }
                XCTAssertEqual(httpCode, 999)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testResourceGetAllRelatedToManyNestedViaSingleton() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        ResourceWithRelationsMock.get(s.networking, id: 42) { result in
            guard case let .success(resource) = result else {
                return XCTFail("Expected .success, got \(result)")
            }

            resource.toManyNested.getAll { relationResult in
                guard case let .failure(error) = relationResult else {
                    return XCTFail("Expected .error, got \(relationResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
                }
                guard case let .unknown(httpCode) = simpleMDMError else {
                    return XCTFail("Expected .unknown, got \(simpleMDMError)")
                }
                XCTAssertEqual(httpCode, 999)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testResourceGetRelatedToManyNestedByIdViaSingleton() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        ResourceWithRelationsMock.get(s.networking, id: 42) { result in
            guard case let .success(resource) = result else {
                return XCTFail("Expected .success, got \(result)")
            }

            resource.toManyNested.get(id: 0) { relationResult in
                guard case let .failure(error) = relationResult else {
                    return XCTFail("Expected .error, got \(relationResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
                }
                guard case let .unknown(httpCode) = simpleMDMError else {
                    return XCTFail("Expected .unknown, got \(simpleMDMError)")
                }
                XCTAssertEqual(httpCode, 999)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
