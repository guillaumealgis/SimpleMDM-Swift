//
//  Copyright 2018 Guillaume Algis.
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

        let cursor = Cursor<Device>()
        cursor.next(-1) { result in
            guard case let .failure(error) = result else {
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

        let cursor = Cursor<Device>()
        cursor.next(0) { result in
            guard case let .failure(error) = result else {
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

        let cursor = Cursor<Device>()
        cursor.next(101) { result in
            guard case let .failure(error) = result else {
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

    func testCursorFetchOnceWithDefaultParamters() {
        let json = loadFixture("Apps")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<App>()
        cursor.next(s.networking) { result in
            guard case let .success(apps) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(apps.count, 5)
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

        let cursor = Cursor<App>()
        cursor.next(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
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
                  "app_type": "app_store",
                  "bundle_identifier": "com.evernote.iPhone.Evernote",
                  "itunes_store_id": 281796108,
                  "name": "Evernote"
                },
                "id": 17851,
                "type": "app"
              }
            ],
            "has_more": true
          }
        """.utf8)
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Cursor next")

        let cursor = Cursor<App>()
        cursor.next(s.networking, 1) { result in
            guard case let .success(apps) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(apps.count, 1)
            XCTAssertTrue(cursor.hasMore)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCursorFetchWithLimitMultipleTimes() {
        func appFixture(name: String, itunesId: Int, id: Int, hasMore: Bool) -> Data {
            let json = Data("""
              {
                "data": [
                  {
                    "attributes": {
                      "app_type": "app_store",
                      "bundle_identifier": "com.example.\(name)",
                      "itunes_store_id": \(itunesId),
                      "name": "\(name)"
                    },
                    "id": \(id),
                    "type": "app"
                  }
                ],
                "has_more": \(hasMore)
              }
            """.utf8)
            return json
        }

        let session = URLSessionMock(routes: [
            "/api/v1/apps?limit=1": Response(data: appFixture(name: "Evernote", itunesId: 2_345_623, id: 737, hasMore: true)),
            "/api/v1/apps?starting_after=737&limit=20": Response(data: appFixture(name: "Instagram", itunesId: 923_646, id: 3462, hasMore: false))
        ])
        let s = SimpleMDM(sessionMock: session)

        let firstFetchSuccess = expectation(description: "First fetch succeeded")
        let secondFetchSuccess = expectation(description: "Second fetch succeeded")

        let cursor = Cursor<App>()
        cursor.next(s.networking, 1) { result in
            guard case let .success(apps) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(apps.count, 1)
            XCTAssertTrue(cursor.hasMore)
            firstFetchSuccess.fulfill()

            cursor.next(s.networking, 20) { result in
                guard case let .success(apps) = result else {
                    return XCTFail("Expected .success, got \(result)")
                }
                XCTAssertEqual(apps.count, 1)
                XCTAssertFalse(cursor.hasMore)
                secondFetchSuccess.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
