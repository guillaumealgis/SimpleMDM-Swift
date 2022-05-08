//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

////
////  Copyright 2022 Guillaume Algis.
////  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
////
//
// @testable import SimpleMDM
// import XCTest
//
///// This class tests whether the exposed API using the SimpleMDM singleton calls to the right Networking instance.
///// We do this by using a networking mock which returns a nonsensical HTTP code, and check in the callback we got
///// this code as expected.
// internal class SimpleMDMSingletonTests: XCTestCase {
//    override func setUp() {
//        let sessionMock = URLSessionMock(responseCode: 999)
//        SimpleMDM.shared.replaceNetworkingSession(session)
//    }
//
//    func testUniqueResourceGetViaSingleton() async throws {
//        await XCTAssertAsyncThrowsError({
//            _ = try await UniqueResourceMock.get()
//        }) { error in
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
//            }
//            guard case let .unknown(httpCode) = simpleMDMError else {
//                return XCTFail("Expected .unknown, got \(simpleMDMError)")
//            }
//            XCTAssertEqual(httpCode, 999)
//        }
//    }
//
//    func testResourceGetAllViaSingleton() async throws {
//        await XCTAssertAsyncThrowsError({
//            _ = try await ResourceMock.all.collect()
//        }) { error in
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
//            }
//            guard case let .unknown(httpCode) = simpleMDMError else {
//                return XCTFail("Expected .unknown, got \(simpleMDMError)")
//            }
//            XCTAssertEqual(httpCode, 999)
//        }
//    }
//
//    func testResourceGetByIdViaSingleton() async throws {
//        await XCTAssertAsyncThrowsError({
//            _ = try await ResourceMock.get(id: 42)
//        }) { error in
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
//            }
//            guard case let .unknown(httpCode) = simpleMDMError else {
//                return XCTFail("Expected .unknown, got \(simpleMDMError)")
//            }
//            XCTAssertEqual(httpCode, 999)
//        }
//    }
//
//    func testResourceGetRelatedToOneViaSingleton() async throws {
//        let json = loadFixture("ResourceWithRelationsMock_42")
//        let firstRequestSession = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(firstRequestSession)
//
//        let rootResource = try await ResourceWithRelationsMock.get(id: 42)
//
//        let secondRequestSession = URLSessionMock(responseCode: 999)
//        SimpleMDM.shared.replaceNetworkingSession(secondRequestSession)
//
//        await XCTAssertAsyncThrowsError({
//            _ = try await rootResource.toOne.get()
//        }) { error in
//
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
//            }
//            guard case let .unknown(httpCode) = simpleMDMError else {
//                return XCTFail("Expected .unknown, got \(simpleMDMError)")
//            }
//            XCTAssertEqual(httpCode, 999)
//        }
//    }
//
//    func testResourceGetAllRelatedToManyViaSingleton() async throws {
//        let json = loadFixture("ResourceWithRelationsMock_42")
//        let firstRequestSession = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(firstRequestSession)
//
//        let rootResource = try await ResourceWithRelationsMock.get(id: 42)
//
//        await XCTAssertAsyncThrowsError({
//            _ = try await rootResource.toMany.collect()
//        }) { error in
//
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
//            }
//            guard case let .unknown(httpCode) = simpleMDMError else {
//                return XCTFail("Expected .unknown, got \(simpleMDMError)")
//            }
//            XCTAssertEqual(httpCode, 999)
//        }
//    }
//
//    func testResourceGetRelatedToManyAtIndexViaSingleton() async throws {
//
//        let json = loadFixture("ResourceWithRelationsMock_42")
//        let firstRequestSession = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(firstRequestSession)
//
//        let rootResource = try await ResourceWithRelationsMock.get(id: 42)
//
//        await XCTAssertAsyncThrowsError({
//            _ = try await rootResource.toMany[0]
//        }) { error in
//
//            guard let simpleMDMError = error as? SimpleMDMError else {
//                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
//            }
//            guard case let .unknown(httpCode) = simpleMDMError else {
//                return XCTFail("Expected .unknown, got \(simpleMDMError)")
//            }
//            XCTAssertEqual(httpCode, 999)
//        }
//    }
//
//    func testResourceGetRelatedToManyByIdViaSingleton() async throws {
//        let json = loadFixture("ResourceWithRelationsMock_42")
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        ResourceWithRelationsMock.get(id: 42) { result in
//            guard case let .fulfilled(resource) = result else {
//                return XCTFail("Expected .fulfilled, got \(result)")
//            }
//
//            resource.toMany.get(id: 0) { relationResult in
//                guard case let .rejected(error) = relationResult else {
//                    return XCTFail("Expected .error, got \(relationResult)")
//                }
//                guard let simpleMDMError = error as? SimpleMDMError else {
//                    return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
//                }
//                guard case let .unknown(httpCode) = simpleMDMError else {
//                    return XCTFail("Expected .unknown, got \(simpleMDMError)")
//                }
//                XCTAssertEqual(httpCode, 999)
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testResourceGetAllRelatedToManyNestedViaSingleton() async throws {
//        let json = loadFixture("ResourceWithRelationsMock_42")
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        ResourceWithRelationsMock.get(id: 42) { result in
//            guard case let .fulfilled(resource) = result else {
//                return XCTFail("Expected .fulfilled, got \(result)")
//            }
//
//            resource.toManyNested.getAll { relationResult in
//                guard case let .rejected(error) = relationResult else {
//                    return XCTFail("Expected .error, got \(relationResult)")
//                }
//                guard let simpleMDMError = error as? SimpleMDMError else {
//                    return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
//                }
//                guard case let .unknown(httpCode) = simpleMDMError else {
//                    return XCTFail("Expected .unknown, got \(simpleMDMError)")
//                }
//                XCTAssertEqual(httpCode, 999)
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
//
//    func testResourceGetRelatedToManyNestedByIdViaSingleton() async throws {
//        let json = loadFixture("ResourceWithRelationsMock_42")
//        let sessionMock = URLSessionMock(data: json, responseCode: 200)
//        SimpleMDM.shared.replaceNetworkingSession(sessionMock)
//
//        let expectation = self.expectation(description: "Callback called")
//
//        ResourceWithRelationsMock.get(id: 42) { result in
//            guard case let .fulfilled(resource) = result else {
//                return XCTFail("Expected .fulfilled, got \(result)")
//            }
//
//            resource.toManyNested.get(id: 0) { relationResult in
//                guard case let .rejected(error) = relationResult else {
//                    return XCTFail("Expected .error, got \(relationResult)")
//                }
//                guard let simpleMDMError = error as? SimpleMDMError else {
//                    return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
//                }
//                guard case let .unknown(httpCode) = simpleMDMError else {
//                    return XCTFail("Expected .unknown, got \(simpleMDMError)")
//                }
//                XCTAssertEqual(httpCode, 999)
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 0.3, handler: nil)
//    }
// }
