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

        networking.getDataForResources(ofType: Device.self) { result in
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

        networking.getDataForResources(ofType: Device.self) { result in
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

        networking.getDataForResources(ofType: Device.self) { result in
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

        networking.getDataForResources(ofType: Device.self) { result in
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

        networking.getDataForResources(ofType: Device.self) { result in
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

        networking.getDataForResources(ofType: Device.self) { result in
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

        networking.getDataForResources(ofType: Device.self) { result in
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

        networking.getDataForResources(ofType: Device.self) { result in
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
        SimpleMDM.useSessionMock(session)

        FakeResource.get { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
        }
    }

    func testMalformedResourceListURL() {
        struct FakeResource: ListableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "💩" }
        }

        let session = URLSessionMock()
        SimpleMDM.useSessionMock(session)

        FakeResource.getAll { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
        }
    }

    func testMalformedResourceWithIdURL() {
        struct FakeResource: GettableResource {
            typealias Identifier = String

            var id: String
            static var endpointName: String { return "💩" }
        }

        let session = URLSessionMock()
        SimpleMDM.useSessionMock(session)

        FakeResource.get(id: "anID") { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
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
        SimpleMDM.useSessionMock(session)

        nestedResources.getAll { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let internalError = error as? InternalError else {
                return XCTFail("Expected error to be a InternalError, got \(error)")
            }
            XCTAssertEqual(internalError, InternalError.malformedURL)
        }
    }
    // swiftlint:enable nesting
}
