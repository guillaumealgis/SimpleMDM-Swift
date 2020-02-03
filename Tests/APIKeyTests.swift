//
//  Copyright 2020 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class APIKeyTests: XCTestCase {
    func testSettingAPIKeyViaSingleton() {
        let apiKey = "AVeryRandomTestAPIKey"
        SimpleMDM.apiKey = apiKey

        XCTAssertEqual(SimpleMDM.apiKey, apiKey)
        XCTAssertEqual(SimpleMDM.shared.networking.apiKey, apiKey)
    }

    func testNotSettingAPIKeyReturnsError() {
        let session = URLSessionMock()
        let networking = Networking(urlSession: session)

        networking.getDataForResources(ofType: Device.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.apiKeyNotSet)
        }
    }

    func testAPIKeyNotSetErrorHasHumanReadableDescription() {
        let session = URLSessionMock()
        let networking = Networking(urlSession: session)

        networking.getDataForResources(ofType: Device.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertTrue(simpleMDMError.localizedDescription.contains("API key was not set"))
        }
    }

    func test401ResponseReturnsInvalidSimpleMDMError() {
        let session = URLSessionMock(responseCode: 401)
        let networking = Networking(urlSession: session)
        networking.apiKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: Device.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.apiKeyInvalid)
        }
    }

    func testInvalidSimpleMDMErrorHasHumanReadableDescription() {
        let session = URLSessionMock(responseCode: 401)
        let networking = Networking(urlSession: session)
        networking.apiKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: Device.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertTrue(simpleMDMError.localizedDescription.contains("server rejected the API key"))
        }
    }
}
