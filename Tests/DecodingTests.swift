//
//  Copyright 2021 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class DecodingTests: XCTestCase {
    func testDecodeInvalidErrorPayload() {
        let json = Data("""
          {
            "unexpected_field": [
              {
                "title": "this is a test error message",
              }
            ]
          }
        """.utf8)
        let decoding = Decoding()

        let networkingResult = NetworkingResult.decodableDataFailure(httpCode: 400, data: json)
        let result = decoding.decodeNetworkingResult(networkingResult, expectedPayloadType: SinglePayload<Device>.self)
        guard case let .rejected(error) = result else {
            return XCTFail("Expected .rejected, got \(result)")
        }
        guard let decodingError = error as? DecodingError else {
            return XCTFail("Expected error to be a DecodingError, got \(error)")
        }
        guard case let .keyNotFound(codingKey, _) = decodingError else {
            return XCTFail("Expected .keyNotFound, got \(decodingError)")
        }
        XCTAssertEqual(codingKey.stringValue, "errors")
    }

    func testDecodeErrorPayloadWithoutError() {
        let json = Data("""
        {
          "errors": []
        }
        """.utf8)
        let decoding = Decoding()

        let networkingResult = NetworkingResult.decodableDataFailure(httpCode: 400, data: json)
        let result = decoding.decodeNetworkingResult(networkingResult, expectedPayloadType: SinglePayload<Device>.self)
        guard case let .rejected(error) = result else {
            return XCTFail("Expected .rejected, got \(result)")
        }
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        XCTAssertEqual(simpleMDMError, SimpleMDMError.unknown(httpCode: 400))
    }

    func testDecodeErrorPayload() {
        let json = Data("""
          {
            "errors": [
              {
                "title": "this is a test error message"
              }
            ]
          }
        """.utf8)
        let decoding = Decoding()

        let networkingResult = NetworkingResult.decodableDataFailure(httpCode: 400, data: json)
        let result = decoding.decodeNetworkingResult(networkingResult, expectedPayloadType: SinglePayload<Device>.self)
        guard case let .rejected(error) = result else {
            return XCTFail("Expected .rejected, got \(result)")
        }
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        XCTAssertEqual(simpleMDMError, SimpleMDMError.generic(httpCode: 400, description: "this is a test error message"))
    }

    func testDecodeErrorPayloadWithMultipleErrors() {
        let json = Data("""
        {
          "errors": [
            {
              "title": "this is the first test error message"
            },
            {
              "title": "this is the second test error message"
            }
          ]
        }
        """.utf8)
        let decoding = Decoding()

        let networkingResult = NetworkingResult.decodableDataFailure(httpCode: 400, data: json)
        let result = decoding.decodeNetworkingResult(networkingResult, expectedPayloadType: SinglePayload<Device>.self)
        guard case let .rejected(error) = result else {
            return XCTFail("Expected .rejected, got \(result)")
        }
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        XCTAssertEqual(simpleMDMError, SimpleMDMError.generic(httpCode: 400, description: "this is the first test error message"))
    }
}
