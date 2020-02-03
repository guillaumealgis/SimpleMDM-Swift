//
//  Copyright 2020 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class CursorTests: XCTestCase {
    func testCursorAtInitHasMoreData() {
        let cursor = Cursor<Device>()
        XCTAssertTrue(cursor.hasMore)
    }

    func testCursorReturnsErrorWithNegativeLimit() {
        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<ResourceMock>()
        cursor.next(-1) { result in
            guard case let .rejected(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.invalidLimit(-1))
            XCTAssertTrue(simpleMDMError.localizedDescription.contains("Limit \"-1\" is invalid"))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCursorReturnsErrorWithLimitEqualToZero() {
        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<ResourceMock>()
        cursor.next(0) { result in
            guard case let .rejected(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.invalidLimit(0))
            XCTAssertTrue(simpleMDMError.localizedDescription.contains("Limit \"0\" is invalid"))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCursorReturnsErrorWithLimitOverAHundred() {
        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<ResourceMock>()
        cursor.next(101) { result in
            guard case let .rejected(error) = result else {
                return XCTFail("Expected .error, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.invalidLimit(101))
            XCTAssertTrue(simpleMDMError.localizedDescription.contains("Limit \"101\" is invalid"))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCursorFetchOnceWithDefaultParameters() {
        let json = loadFixture("ResourcesMock")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<ResourceMock>()
        cursor.next(s.networking) { result in
            guard case let .fulfilled(resources) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(resources.count, 5)
            XCTAssertFalse(cursor.hasMore)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCursorFetchedNothingButAdvertisedMore() {
        let json = Data("""
          {
            "data": [],
            "has_more": true
          }
        """.utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<ResourceMock>()
        cursor.next(s.networking) { result in
            guard case let .rejected(error) = result else {
                return XCTFail("Expected .rejected, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.doesNotExpectMoreResources)
            XCTAssertEqual(simpleMDMError.localizedDescription, "No resource was fetched, but the server advertised for more resources")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCursorFetchWithLimit() {
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
        cursor.next(s.networking, 1) { result in
            guard case let .fulfilled(resources) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(resources.count, 1)
            XCTAssertTrue(cursor.hasMore)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCursorFetchWithLimitMultipleTimes() {
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
        cursor.next(s.networking, 1) { result in
            guard case let .fulfilled(resources) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(resources.count, 1)
            XCTAssertTrue(cursor.hasMore)
            firstFetchSuccess.fulfill()

            cursor.next(s.networking, 20) { result in
                guard case let .fulfilled(resources) = result else {
                    return XCTFail("Expected .fulfilled, got \(result)")
                }
                XCTAssertEqual(resources.count, 1)
                XCTAssertFalse(cursor.hasMore)
                secondFetchSuccess.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
