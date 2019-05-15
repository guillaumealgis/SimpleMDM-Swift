//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class APIKeyTests: XCTestCase {
    func testSettingAPIKeyViaSingleton() {
        let APIKey = "AVeryRandomTestAPIKey"
        SimpleMDM.APIKey = APIKey

        XCTAssertEqual(SimpleMDM.APIKey, APIKey)
        XCTAssertEqual(SimpleMDM.shared.networking.APIKey, APIKey)
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
            XCTAssertEqual(simpleMDMError, SimpleMDMError.APIKeyNotSet)
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
        networking.APIKey = "AVeryRandomTestAPIKey"

        networking.getDataForResources(ofType: Device.self) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected .failure, got \(result)")
            }
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.APIKeyInvalid)
        }
    }

    func testInvalidSimpleMDMErrorHasHumanReadableDescription() {
        let session = URLSessionMock(responseCode: 401)
        let networking = Networking(urlSession: session)
        networking.APIKey = "AVeryRandomTestAPIKey"

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
