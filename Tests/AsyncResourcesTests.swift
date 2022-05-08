//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class AsyncResourcesTests: XCTestCase {
    var sessionMock: URLSessionMock!

    override func setUp() {
        let json = loadFixture("ResourcesMock")
        sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
    }

    func testAsyncResourcesFetchOnceWithDefaultParameters() async throws {
        let resources = AsyncResources<ResourceMock>()
        var iterator = resources.makeAsyncIterator()
        let nextResource = try await iterator.next()

        XCTAssertNotNil(nextResource)
    }

    func testAsyncResourcesFetchedNothingButAdvertisedMore() async throws {
        let json = Data("""
          {
            "data": [],
            "has_more": true
          }
        """.utf8)
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let resources = AsyncResources<ResourceMock>()
        var iterator = resources.makeAsyncIterator()
        await XCTAssertAsyncThrowsError({
            try await iterator.next()
        }, "Expected a thrown SimpleMDMError.doesNotExpectMoreResources", { error in
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExpectMoreResources)
            XCTAssertEqual(simpleMDMError.localizedDescription, "No resource was fetched, but the server advertised for more resources")
        })
    }

    func testAsyncResourcesFetchMultipleTimes() async throws {
        let resources = AsyncResources<ResourceMock>()
        var iterator = resources.makeAsyncIterator()

        let firstResourceOrNil = try await iterator.next()
        let firstResource = try XCTUnwrap(firstResourceOrNil)
        XCTAssertEqual(firstResource.id, 923)

        let secondResourceOrNil = try await iterator.next()
        let secondResource = try XCTUnwrap(secondResourceOrNil)
        XCTAssertEqual(secondResource.id, 345)
    }

    func testAsyncResourcesNextReturnsNilWhenNoMoreResourceAvailable() async throws {
        let resources = AsyncResources<ResourceMock>()
        var iterator = resources.makeAsyncIterator()

        for _ in 1 ... 5 {
            let resource = try await iterator.next()
            XCTAssertNotNil(resource)
        }

        let next = try await iterator.next()
        XCTAssertNil(next)
    }

    func testAllAsyncResourcesCanBeFetchedAtOnce() async throws {
        let resources = AsyncResources<ResourceMock>()
        let fetchedResources = try await resources.collect()

        XCTAssertEqual(fetchedResources.count, 5)
    }

    func testAllAsyncResourcesCanBeFetchedUsingForIn() async throws {
        let resources = AsyncResources<ResourceMock>()
        for try await resource in resources {
            XCTAssertNotNil(resource)
        }
    }

    func testAsyncResourcesAreFetchedInOrder() async throws {
        let resources = AsyncResources<ResourceMock>()
        let fetchedResources = try await resources.collect()

        XCTAssertEqual(fetchedResources[0].id, 923)
        XCTAssertEqual(fetchedResources[1].id, 345)
        XCTAssertEqual(fetchedResources[2].id, 8762)
        XCTAssertEqual(fetchedResources[3].id, 3)
        XCTAssertEqual(fetchedResources[4].id, 9021)
    }

    func testFetchingAllAsyncResourcesOnlyDoesOneRequest() async throws {
        let resources = AsyncResources<ResourceMock>()
        _ = try await resources.collect()

        XCTAssertEqual(sessionMock.handledRequests.count, 1)
    }

    // MARK: - Related

    func testFetchingRelatedToManyResources() async throws {
        let sessionMock = URLSessionMock(routes: [
            "/api/v1/resource_with_relations_mock/42": Response(data: loadFixture("ResourceWithRelationsMock_42")),
            "/api/v1/resource_mock/78": Response(data: loadFixture("ResourceMock_78")),
            "/api/v1/resource_mock/326": Response(data: loadFixture("ResourceMock_326"))
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        var expectedIds: ArraySlice<Int> = [326, 78]

        let resource = try await ResourceWithRelationsMock.get(id: 42)
        for try await relatedResource in resource.toMany {
            XCTAssertEqual(relatedResource.id, expectedIds.popFirst())
        }

        XCTAssertEqual(sessionMock.handledRequests.count, 3)
    }
}
