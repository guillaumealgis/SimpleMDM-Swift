//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class NetworkingTests: XCTestCase {
    func testReturnUnknownErrorIfRequestFails() {
        let session = URLSessionMock(data: nil)
        let networking = Networking(urlSession: session)
        networking.APIKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: ResourceMock.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.unknown)
        }
    }

    func testUnknownErrorHasHumanReadableDescription() {
        let session = URLSessionMock(data: nil)
        let networking = Networking(urlSession: session)
        networking.APIKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: ResourceMock.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError.localizedDescription, "Unknown network error")
        }
    }

    func testReturnNoHTTPResponseIfNoResponseReturned() {
        let session = URLSessionMock()
        let networking = Networking(urlSession: session)
        networking.APIKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: ResourceMock.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.noHTTPResponse)
        }
    }

    func testNoHTTPResponseErrorHasHumanReadableDescription() {
        let session = URLSessionMock()
        let networking = Networking(urlSession: session)
        networking.APIKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: ResourceMock.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError.localizedDescription, "Did not receive a HTTP response")
        }
    }

    func testReturnErrorForHTMLMimeType() {
        let mimeType = "text/html"
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networking = Networking(urlSession: session)
        networking.APIKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: ResourceMock.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.unexpectedMimeType(mimeType))
        }
    }

    func testReturnErrorForNullMimeType() {
        let mimeType: String? = nil
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networking = Networking(urlSession: session)
        networking.APIKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: ResourceMock.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertEqual(networkError, NetworkError.unexpectedMimeType(mimeType))
        }
    }

    func testInvalidMimeTypeErrorHasHumanReadableDescription() {
        let mimeType = "text/html"
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networking = Networking(urlSession: session)
        networking.APIKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: ResourceMock.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertTrue(networkError.localizedDescription.contains(mimeType))
        }
    }

    func testNullMimeTypeErrorHasHumanReadableDescription() {
        let mimeType: String? = nil
        let session = URLSessionMock(responseCode: 200, responseMimeType: mimeType)
        let networking = Networking(urlSession: session)
        networking.APIKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: ResourceMock.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let networkError = error as? NetworkError else {
                return XCTFail("Expected error to be a NetworkError, got \(error)")
            }
            XCTAssertTrue(networkError.localizedDescription.contains("null"))
        }
    }

    // swiftlint:disable nesting
    func testMalformedUniqueResourceURL() {
        struct FakeResource: UniqueResource {
            static var endpointName: String { return "💩" }
        }

        let session = URLSessionMock()
        let s = SimpleMDM(sessionMock: session)

        FakeResource.get(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testMalformedResourceListURL() {
        struct FakeResource: ListableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "💩" }
        }

        let session = URLSessionMock()
        let s = SimpleMDM(sessionMock: session)

        FakeResource.getAll(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testMalformedResourceWithIdURL() {
        struct FakeResource: GettableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "💩" }
        }

        let session = URLSessionMock()
        let s = SimpleMDM(sessionMock: session)

        FakeResource.get(s.networking, id: "anID") { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testMalformedResourceSearchURL() {
        struct FakeResource: SearchableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "💩" }
        }

        let session = URLSessionMock()
        let s = SimpleMDM(sessionMock: session)

        let cursor = SearchCursor<FakeResource>(searchString: "Foobar")
        cursor.next(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testMalformedNestedResourceURL() {
        struct FakeResource: IdentifiableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "fake_endpoint" }
        }

        struct FakeNestedResource: IdentifiableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "💩" }
        }

        let nestedResources = RelatedToManyNested<FakeResource, FakeNestedResource>(parentId: "fakeId")

        let session = URLSessionMock()
        let s = SimpleMDM(sessionMock: session)

        nestedResources.getAll(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testNestedListableResourceWithMalformedParentResourceURL() {
        struct FakeResource: IdentifiableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "💩" }
        }

        struct FakeNestedResource: ListableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "nested_endpoint" }
        }

        let nestedResources = NestedResourceCursor<FakeResource, FakeNestedResource>(parentId: "fakeId")

        let session = URLSessionMock()
        let s = SimpleMDM(sessionMock: session)

        nestedResources.next(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    func testMalformedNestedListableResourceURL() {
        struct FakeResource: IdentifiableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "fake_endpoint" }
        }

        struct FakeNestedResource: ListableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "💩" }
        }

        let nestedResources = NestedResourceCursor<FakeResource, FakeNestedResource>(parentId: "fakeId")

        let session = URLSessionMock()
        let s = SimpleMDM(sessionMock: session)

        nestedResources.next(s.networking) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
            XCTAssertEqual(internalError.localizedDescription, "The URL could not be constructed")
        }
    }

    // swiftlint:enable nesting
}
