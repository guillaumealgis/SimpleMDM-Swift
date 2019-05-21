//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import PromiseKit
@testable import SimpleMDM
import XCTest

/// This class tests the PromiseKit bindings of the resources when using the SimpleMDM singleton.
/// The method of testing is the same than in SimpleMDMSingletonTests.swift (we use a networking mock which returns a
/// nonsensical HTTP code, and check that the promise errors on this HTTP code).
internal class SimpleMDMSingletonPromiseKitTests: XCTestCase {
    override static func setUp() {
        let session = URLSessionMock(responseCode: 999)
        let networking = Networking(urlSession: session)
        networking.APIKey = "AGlobalAndRandomAPIKey"
        SimpleMDM.shared.networking = networking
    }

    func assertUsingSingleton(error: Error) {
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        guard case let .unknown(httpCode) = simpleMDMError else {
            return XCTFail("Expected .unknown, got \(simpleMDMError)")
        }
        XCTAssertEqual(httpCode, 999)
    }

    func testPromisesGetUniqueResource() {
        let expectation = self.expectation(description: "Callback called")

        firstly {
            UniqueResourceMock.get()
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllResources() {
        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceMock.getAll()
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetResourceById() {
        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceMock.get(id: 37)
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetRelatedToOne() {
        let session = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: loadFixture("ResourceWithRelationsMock_42")),
            "/api/v1/resource_mock/37": Response(data: loadFixture("ResourceMock_37"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<ResourceMock> in
            XCTAssertEqual(resource.id, 42)
            return resource.toOne.get()
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetRelatedToOneError() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<ResourceMock> in
            XCTAssertEqual(resource.id, 42)
            return resource.toOne.get()
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllRelatedToMany() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<[ResourceMock]> in
            XCTAssertEqual(resource.id, 42)
            return resource.toMany.getAll()
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetRelatedToManyAtIndex() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<ResourceMock> in
            XCTAssertEqual(resource.id, 42)
            return resource.toMany.get(at: 1)
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetRelatedToManyById() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<ResourceMock> in
            XCTAssertEqual(resource.id, 42)
            return resource.toMany.get(id: 326)
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllRelatedToManyNested() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<[ResourceMock]> in
            XCTAssertEqual(resource.id, 42)
            return resource.toManyNested.getAll()
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllRelatedToManyNestedErrorOnRelationFetch() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<[ResourceMock]> in
            XCTAssertEqual(resource.id, 42)
            return resource.toManyNested.getAll()
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetRelatedToManyNestedById() {
        let json = loadFixture("ResourceWithRelationsMock_42")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<ResourceMock> in
            XCTAssertEqual(resource.id, 42)
            return resource.toManyNested.get(id: 8762)
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesCursorFetchOnceWithDefaultParameters() {
        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<ResourceMock>()
        firstly {
            cursor.next()
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesCursorFetchWithLimit() {
        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<ResourceMock>()
        firstly {
            cursor.next(1)
        }.done { _ in
            XCTFail("Expected an error, SimpleMDM singleton probably wasn't used")
        }.catch { error in
            self.assertUsingSingleton(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
