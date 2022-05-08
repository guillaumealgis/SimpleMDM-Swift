//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class NetworkingTests: XCTestCase {
    func testReturnUnknownErrorIfRequestFails() async throws {
        let sessionMock = URLSessionMock(data: nil, responseCode: 500)
        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomTestAPIKey"

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: ResourceMock.self)
        }) { error in
            guard let networkError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(networkError, SimpleMDMError.unknown(httpCode: 500))
        }
    }

    func testUnknownErrorHasHumanReadableDescription() async throws {
        let sessionMock = URLSessionMock(data: nil, responseCode: 500)
        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomTestAPIKey"

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: ResourceMock.self)
        }) { error in
            guard let networkError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be a SimpleMDMError, got \(error)")
            }
            XCTAssertTrue(networkError.localizedDescription.starts(with: "Unknown API error"))
        }
    }

    func testReturnNoHTTPResponseIfNoResponseReturned() async throws {
        let sessionMock = URLSessionMock(data: nil)
        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomTestAPIKey"

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: ResourceMock.self)
        }) { error in
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.noHTTPResponse)
        }
    }

    func testNoHTTPResponseErrorHasHumanReadableDescription() async throws {
        let sessionMock = URLSessionMock(data: nil)
        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomTestAPIKey"

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: ResourceMock.self)
        }) { error in
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError.localizedDescription, "Did not receive a HTTP response")
        }
    }

    func testReturnErrorForHTMLMimeType() async throws {
        let mimeType = "text/html"
        let sessionMock = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomTestAPIKey"

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: ResourceMock.self)
        }) { error in
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.unexpectedMimeType(mimeType))
        }
    }

    func testReturnErrorForNullMimeType() async throws {
        let mimeType: String? = nil
        let sessionMock = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomTestAPIKey"

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: ResourceMock.self)
        }) { error in
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.unexpectedMimeType(mimeType))
        }
    }

    func testInvalidMimeTypeErrorHasHumanReadableDescription() async throws {
        let mimeType = "text/html"
        let sessionMock = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomTestAPIKey"

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: ResourceMock.self)
        }) { error in
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertTrue(networkError.localizedDescription.contains(mimeType))
        }
    }

    func testNullMimeTypeErrorHasHumanReadableDescription() async throws {
        let mimeType: String? = nil
        let sessionMock = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomTestAPIKey"

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: ResourceMock.self)
        }) { error in
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertTrue(networkError.localizedDescription.contains("null"))
        }
    }

    // swiftlint:disable nesting
    func testMalformedUniqueResourceURL() async throws {
        struct FakeResource: UniqueResource {
            static var endpointName: String { "💩" }
        }

        let sessionMock = URLSessionMock()
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        await XCTAssertAsyncThrowsError({
            try await FakeResource.get()
        }) { error in
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testMalformedResourceListURL() async throws {
        struct FakeResource: FetchableListableResource {
            typealias ID = String

            var id: ID
            static var endpointName: String { "💩" }
        }

        let sessionMock = URLSessionMock()
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        await XCTAssertAsyncThrowsError({
            _ = try await FakeResource.all.collect()
        }) { error in
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testMalformedResourceWithIdURL() async throws {
        struct FakeResource: GettableResource {
            typealias ID = String

            var id: ID
            static var endpointName: String { "💩" }
        }

        let sessionMock = URLSessionMock()
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        await XCTAssertAsyncThrowsError({
            try await FakeResource.get(id: "anID")
        }) { error in
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testMalformedResourceSearchURL() async throws {
        struct FakeResource: SearchableResource {
            typealias ID = String

            var id: ID
            static var endpointName: String { "💩" }
        }

        let sessionMock = URLSessionMock()
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        await XCTAssertAsyncThrowsError({
            let results = try await FakeResource.search("Foobar")
            _ = try await results.collect()
        }) { error in
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testMalformedNestedResourceURL() async throws {
        struct FakeResource: IdentifiableResource {
            typealias ID = String

            var id: ID
            static var endpointName: String { "fake_endpoint" }
        }

        struct FakeNestedResource: ListableResource {
            typealias ID = String

            var id: ID
            static var endpointName: String { "💩" }
        }

        let nestedResources = RelatedToManyNested<FakeResource, FakeNestedResource>(parentId: "fakeId")

        let sessionMock = URLSessionMock()
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        await XCTAssertAsyncThrowsError({
            _ = try await nestedResources.collect()
        }) { error in
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testNestedListableResourceWithMalformedParentResourceURL() async throws {
        struct FakeResource: IdentifiableResource {
            typealias ID = String

            var id: ID
            static var endpointName: String { "💩" }
        }

        struct FakeNestedResource: ListableResource {
            typealias ID = String

            var id: ID
            static var endpointName: String { "nested_endpoint" }
        }

        let nestedResources = RelatedToManyNested<FakeResource, FakeNestedResource>(parentId: "fakeId")

        let sessionMock = URLSessionMock()
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        await XCTAssertAsyncThrowsError({
            _ = try await nestedResources.collect()
        }) { error in
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testMalformedNestedListableResourceURL() async throws {
        struct FakeResource: IdentifiableResource {
            typealias ID = String

            var id: ID
            static var endpointName: String { "fake_endpoint" }
        }

        struct FakeNestedResource: ListableResource {
            typealias ID = String

            var id: ID
            static var endpointName: String { "💩" }
        }

        let nestedResources = RelatedToManyNested<FakeResource, FakeNestedResource>(parentId: "fakeId")

        let sessionMock = URLSessionMock()
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        await XCTAssertAsyncThrowsError({
            try await nestedResources.collect()
        }) { error in
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    // swiftlint:enable nesting
}
