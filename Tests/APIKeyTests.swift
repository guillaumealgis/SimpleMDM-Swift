//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class APIKeyTests: XCTestCase {
    func testSettingAPIKeyViaSingleton() async throws {
        let apiKey = "AVeryRandomTestAPIKey"
        SimpleMDM.apiKey = apiKey

        XCTAssertEqual(SimpleMDM.apiKey, apiKey)
        XCTAssertEqual(SimpleMDM.shared.networking.apiKey, apiKey)
    }

    func testNotSettingAPIKeyReturnsError() async throws {
        let sessionMock = URLSessionMock()
        let networking = Networking(urlSession: sessionMock)

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: Device.self)
        }, "Expected a thrown SimpleMDMError.apiKeyNotSet", { error in
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.apiKeyNotSet)
        })
    }

    func testAPIKeyNotSetErrorHasHumanReadableDescription() async throws {
        let sessionMock = URLSessionMock()
        let networking = Networking(urlSession: sessionMock)

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: Device.self)
        }, "Expected a thrown SimpleMDMError.apiKeyNotSet", { error in
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertTrue(simpleMDMError.localizedDescription.contains("API key was not set"))
        })
    }

    func test401ResponseReturnsInvalidSimpleMDMError() async throws {
        let sessionMock = URLSessionMock(responseCode: 401)
        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomTestAPIKey"

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: Device.self)
        }, "Expected a thrown SimpleMDMError.apiKeyInvalid", { error in
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.apiKeyInvalid)
        })
    }

    func testInvalidSimpleMDMErrorHasHumanReadableDescription() async throws {
        let sessionMock = URLSessionMock(responseCode: 401)
        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomTestAPIKey"

        await XCTAssertAsyncThrowsError({
            try await networking.getDataForResources(ofType: Device.self)
        }, "Expected a thrown SimpleMDMError.apiKeyInvalid", { error in
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertTrue(simpleMDMError.localizedDescription.contains("server rejected the API key"))
        })
    }
}
