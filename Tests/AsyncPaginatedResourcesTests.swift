//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

//
//
////
////  Copyright 2021 Guillaume Algis.
////  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
////
//
// @testable import SimpleMDM
// import XCTest
//
// internal class AsyncPaginatedResourcesTests: XCTestCase {
//    func testAsyncPaginatedResourcesAtInitHasMoreData() async throws {
//        let cursor = AsyncPaginatedResources<Device>()
//        XCTAssertTrue(cursor.hasMore)
//    }
//
//    func testAsyncPaginatedResourcesReturnsErrorWithNegativeLimit() async throws {
//        var resources = AsyncPaginatedResources<ResourceMock>()
//        await XCTAssertAsyncThrowsError({
//            try await resources.nextPage(limit: -1)
//        }, "Expected a thrown SimpleMDMError.invalidLimit", { error in
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//            }
//            XCTAssertEqual(simpleMDMError, SimpleMDMError.invalidLimit(-1))
//            XCTAssertTrue(simpleMDMError.localizedDescription.contains("Limit \"-1\" is invalid"))
//        })
//    }
//
//    func testAsyncPaginatedSequenceReturnsErrorWithLimitEqualToZero() async throws {
//        var resources = AsyncPaginatedResources<ResourceMock>()
//        await XCTAssertAsyncThrowsError({
//            try await resources.nextPage(limit: 0)
//        }, "Expected a thrown SimpleMDMError.invalidLimit", { error in
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//            }
//            XCTAssertEqual(simpleMDMError, SimpleMDMError.invalidLimit(0))
//            XCTAssertTrue(simpleMDMError.localizedDescription.contains("Limit \"0\" is invalid"))
//        })
//    }
//
//    func testAsyncPaginatedSequenceReturnsErrorWithLimitOverAHundred() async throws {
//        var resources = AsyncPaginatedResources<ResourceMock>()
//        await XCTAssertAsyncThrowsError({
//            try await resources.nextPage(limit: 101)
//        }, "Expected a thrown SimpleMDMError.invalidLimit", { error in
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//            }
//            XCTAssertEqual(simpleMDMError, SimpleMDMError.invalidLimit(101))
//            XCTAssertTrue(simpleMDMError.localizedDescription.contains("Limit \"101\" is invalid"))
//        })
//    }
//
//    func testAsyncPaginatedSequenceFetchOnePageWithDefaultParameters() async throws {
//        let json = loadFixture("ResourcesMock")
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Cursor next")
//
//        var resources = AsyncPaginatedResources<ResourceMock>(networking: )
//        try await resources.nextPage()
//
//
//        let cursor = Cursor<ResourceMock>()
//        cursor.next() { result in
//            guard case let .fulfilled(resources) = result else {
//                return XCTFail("Expected .fulfilled, got \(result)")
//            }
//            XCTAssertEqual(resources.count, 5)
//            XCTAssertFalse(cursor.hasMore)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testCursorFetchedNothingButAdvertisedMore() async throws {
//        let json = Data("""
//          {
//            "data": [],
//            "has_more": true
//          }
//        """.utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Cursor next")
//
//        let cursor = Cursor<ResourceMock>()
//        cursor.next() { result in
//            guard case let .rejected(error) = result else {
//                return XCTFail("Expected .rejected, got \(result)")
//            }
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
//            }
//            XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExpectMoreResources)
//            XCTAssertEqual(simpleMDMError.localizedDescription, "No resource was fetched, but the server advertised for more resources")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testCursorFetchWithLimit() async throws {
//        let json = Data("""
//          {
//            "data": [
//              {
//                "attributes": {
//                },
//                "id": 3454,
//                "type": "resource_mock"
//              }
//            ],
//            "has_more": true
//          }
//        """.utf8)
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Cursor next")
//
//        let cursor = Cursor<ResourceMock>()
//        cursor.next(1) { result in
//            guard case let .fulfilled(resources) = result else {
//                return XCTFail("Expected .fulfilled, got \(result)")
//            }
//            XCTAssertEqual(resources.count, 1)
//            XCTAssertTrue(cursor.hasMore)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testCursorFetchWithLimitMultipleTimes() async throws {
//        // Local function used to define a new fixture on the fly
//        func resourceMockFixture(id: Int, hasMore: Bool) -> Data {
//            let json = Data("""
//              {
//                "data": [
//                  {
//                    "attributes": {
//                    },
//                    "id": \(id),
//                    "type": "resource_mock"
//                  }
//                ],
//                "has_more": \(hasMore)
//              }
//            """.utf8)
//            return json
//        }
//
//        let sessionMock = URLSessionMock(routes: [
//            "/api/v1/resource_mock?limit=1": Response(data: resourceMockFixture(id: 737, hasMore: true)),
//            "/api/v1/resource_mock?starting_after=737&limit=20": Response(data: resourceMockFixture(id: 3462, hasMore: false))
//        ])
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let firstFetchSuccess = expectation(description: "First fetch succeeded")
//        let secondFetchSuccess = expectation(description: "Second fetch succeeded")
//
//        let cursor = Cursor<ResourceMock>()
//        cursor.next(1) { result in
//            guard case let .fulfilled(resources) = result else {
//                return XCTFail("Expected .fulfilled, got \(result)")
//            }
//            XCTAssertEqual(resources.count, 1)
//            XCTAssertTrue(cursor.hasMore)
//            firstFetchSuccess.fulfill()
//
//            cursor.next(20) { result in
//                guard case let .fulfilled(resources) = result else {
//                    return XCTFail("Expected .fulfilled, got \(result)")
//                }
//                XCTAssertEqual(resources.count, 1)
//                XCTAssertFalse(cursor.hasMore)
//                secondFetchSuccess.fulfill()
//            }
////        }
////
////        waitForExpectations(timeout: 0.3, handler: nil)
////    }
//// }
