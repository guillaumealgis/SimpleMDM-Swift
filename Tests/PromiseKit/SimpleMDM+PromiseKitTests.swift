//
//  Copyright 2020 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import PromiseKit
@testable import SimpleMDM
import XCTest

/// This class tests the PromiseKit bindings of the resources.
internal class SimpleMDMPromiseKitTests: XCTestCase {
    let error404Json = """
      {
        "errors": [
          {
            "title": "object not found"
          }
        ]
      }
    """.data(using: .utf8)

    func assert404(error: Error) {
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExist)
        XCTAssertTrue(simpleMDMError.localizedDescription.contains("does not exist"))
    }

    func testPromisesGetUniqueResource() {
        let json = loadFixture("UniqueResourceMock")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            UniqueResourceMock.get(s.networking)
        }.done { _ in
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetUniqueResourceError() {
        let session = URLSessionMock(data: error404Json, responseCode: 404)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            UniqueResourceMock.get(s.networking)
        }.done { resource in
            XCTFail("Expected .error, got \(resource)")
        }.catch { error in
            self.assert404(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllResources() {
        let json = loadFixture("ResourcesMock")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceMock.getAll(s.networking)
        }.done { resources in
            XCTAssertEqual(resources.count, 5)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllResourcesError() {
        let session = URLSessionMock(data: error404Json, responseCode: 404)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceMock.getAll(s.networking)
        }.done { resources in
            XCTFail("Expected .error, got \(resources)")
        }.catch { error in
            self.assert404(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetResourceById() {
        let json = loadFixture("ResourceMock_37")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceMock.get(s.networking, id: 37)
        }.done { resource in
            XCTAssertEqual(resource.id, 37)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetResourceByIdError() {
        let session = URLSessionMock(data: error404Json, responseCode: 404)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceMock.get(s.networking, id: 37)
        }.done { resources in
            XCTFail("Expected .error, got \(resources)")
        }.catch { error in
            self.assert404(error: error)
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
            return resource.toOne.get(s.networking)
        }.done { relatedResource in
            XCTAssertEqual(relatedResource.id, 37)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetRelatedToOneError() {
        let session = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: loadFixture("ResourceWithRelationsMock_42")),
            "/api/v1/resource_mock/37": Response(data: error404Json, code: 404)
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<ResourceMock> in
            XCTAssertEqual(resource.id, 42)
            return resource.toOne.get(s.networking)
        }.done { relatedResource in
            XCTFail("Expected .error, got \(relatedResource)")
        }.catch { error in
            self.assert404(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllRelatedToMany() {
        let session = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: loadFixture("ResourceWithRelationsMock_42")),
            "/api/v1/resource_mock/326": Response(data: loadFixture("ResourceMock_326")),
            "/api/v1/resource_mock/78": Response(data: loadFixture("ResourceMock_78"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<[ResourceMock]> in
            XCTAssertEqual(resource.id, 42)
            return resource.toMany.getAll(s.networking)
        }.done { relatedResources in
            XCTAssertEqual(relatedResources.map { $0.id }, [326, 78])
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllRelatedToManyErrorOnFirstFetch() {
        let session = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: error404Json, code: 404),
            "/api/v1/resource_mock/326": Response(data: loadFixture("ResourceMock_326")),
            "/api/v1/resource_mock/78": Response(data: loadFixture("ResourceMock_78"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<[ResourceMock]> in
            XCTAssertEqual(resource.id, 42)
            return resource.toMany.getAll(s.networking)
        }.done { resources in
            XCTFail("Expected .error, got \(resources)")
        }.catch { error in
            self.assert404(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllRelatedToManyErrorOnRelationFetch() {
        let session = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: loadFixture("ResourceWithRelationsMock_42")),
            "/api/v1/resource_mock/326": Response(data: error404Json, code: 404),
            "/api/v1/resource_mock/78": Response(data: loadFixture("ResourceMock_78"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<[ResourceMock]> in
            XCTAssertEqual(resource.id, 42)
            return resource.toMany.getAll(s.networking)
        }.done { resources in
            XCTFail("Expected .error, got \(resources)")
        }.catch { error in
            self.assert404(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetRelatedToManyAtIndex() {
        let session = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: loadFixture("ResourceWithRelationsMock_42")),
            "/api/v1/resource_mock/78": Response(data: loadFixture("ResourceMock_78"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<ResourceMock> in
            XCTAssertEqual(resource.id, 42)
            return resource.toMany.get(s.networking, at: 1)
        }.done { relatedResource in
            XCTAssertEqual(relatedResource.id, 78)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetRelatedToManyById() {
        let session = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: loadFixture("ResourceWithRelationsMock_42")),
            "/api/v1/resource_mock/326": Response(data: loadFixture("ResourceMock_326"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<ResourceMock> in
            XCTAssertEqual(resource.id, 42)
            return resource.toMany.get(s.networking, id: 326)
        }.done { relatedResource in
            XCTAssertEqual(relatedResource.id, 326)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllRelatedToManyNested() {
        let session = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: loadFixture("ResourceWithRelationsMock_42")),
            "/api/v1/resource_with_relations_mock/42/resource_mock": Response(data: loadFixture("ResourcesMock"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<[ResourceMock]> in
            XCTAssertEqual(resource.id, 42)
            return resource.toManyNested.getAll(s.networking)
        }.done { relatedResources in
            XCTAssertEqual(relatedResources.map { $0.id }, [923, 345, 8762, 3, 9021])
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetAllRelatedToManyNestedErrorOnRelationFetch() {
        let session = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: loadFixture("ResourceWithRelationsMock_42")),
            "/api/v1/resource_with_relations_mock/42/resource_mock": Response(data: error404Json, code: 404)
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<[ResourceMock]> in
            XCTAssertEqual(resource.id, 42)
            return resource.toManyNested.getAll(s.networking)
        }.done { resources in
            XCTFail("Expected .error, got \(resources)")
        }.catch { error in
            self.assert404(error: error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesGetRelatedToManyNestedById() {
        let session = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: loadFixture("ResourceWithRelationsMock_42")),
            "/api/v1/resource_with_relations_mock/42/resource_mock": Response(data: loadFixture("ResourcesMock"))
        ])
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        firstly {
            ResourceWithRelationsMock.get(s.networking, id: 42)
        }
        .then { (resource: ResourceWithRelationsMock) -> Promise<ResourceMock> in
            XCTAssertEqual(resource.id, 42)
            return resource.toManyNested.get(s.networking, id: 8762)
        }.done { relatedResource in
            XCTAssertEqual(relatedResource.id, 8762)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesCursorFetchOnceWithDefaultParameters() {
        let json = loadFixture("ResourcesMock")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<ResourceMock>()
        firstly {
            cursor.next(s.networking)
        }
        .done { resources in
            XCTAssertEqual(resources.count, 5)
            XCTAssertFalse(cursor.hasMore)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesCursorFetchWithLimit() {
        let json = Data("""
          {
            "data": [
              {
                "attributes": {
                },
                "id": 3454,
                "type": "resource_mock"
              }
            ],
            "has_more": true
          }
        """.utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<ResourceMock>()
        firstly {
            cursor.next(s.networking, 1)
        }
        .done { resources in
            XCTAssertEqual(resources.count, 1)
            XCTAssertTrue(cursor.hasMore)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPromisesCursorFetchWithLimitMultipleTimes() {
        // Local function used to define a new fixture on the fly
        func resourceMockFixture(id: Int, hasMore: Bool) -> Data {
            let json = Data("""
            {
                "data": [
                  {
                    "attributes": {
                    },
                    "id": \(id),
                    "type": "resource_mock"
                  }
                ],
                "has_more": \(hasMore)
              }
            """.utf8)
            return json
        }

        let session = URLSessionMock(routes: [
            "/api/v1/resource_mock?limit=1": Response(data: resourceMockFixture(id: 737, hasMore: true)),
            "/api/v1/resource_mock?starting_after=737&limit=20": Response(data: resourceMockFixture(id: 3462, hasMore: false))
        ])
        let s = SimpleMDM(sessionMock: session)

        let firstFetchSuccess = expectation(description: "First fetch succeeded")
        let secondFetchSuccess = expectation(description: "Second fetch succeeded")

        let cursor = Cursor<ResourceMock>()
        firstly {
            cursor.next(s.networking, 1)
        }
        .then { (resources: [ResourceMock]) -> Promise<[ResourceMock]> in
            XCTAssertEqual(resources.count, 1)
            XCTAssertTrue(cursor.hasMore)
            firstFetchSuccess.fulfill()

            return cursor.next(s.networking, 20)
        }
        .done { resources in
            XCTAssertEqual(resources.count, 1)
            XCTAssertFalse(cursor.hasMore)
            secondFetchSuccess.fulfill()
        }
        .catch { error in
            XCTFail("Expected .fulfilled, got \(error)")
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
