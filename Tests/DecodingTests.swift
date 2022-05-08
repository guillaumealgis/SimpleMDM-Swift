//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class DecodingTests: XCTestCase {
    func testDecodeInvalidErrorPayload() async throws {
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

        let error = decoding.decodeError(from: json, httpCode: 400)
        guard let decodingError = error as? DecodingError else {
            return XCTFail("Expected error to be a DecodingError, got \(error)")
        }
        guard case let .keyNotFound(codingKey, _) = decodingError else {
            return XCTFail("Expected .keyNotFound, got \(decodingError)")
        }
        XCTAssertEqual(codingKey.stringValue, "errors")
    }

    func testDecodeErrorPayloadWithoutError() async throws {
        let json = Data("""
        {
          "errors": []
        }
        """.utf8)
        let decoding = Decoding()

        let error = decoding.decodeError(from: json, httpCode: 400)
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        XCTAssertEqual(simpleMDMError, SimpleMDMError.unknown(httpCode: 400))
    }

    func testDecodeErrorPayload() async throws {
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

        let error = decoding.decodeError(from: json, httpCode: 400)
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        XCTAssertEqual(simpleMDMError, SimpleMDMError.generic(httpCode: 400, description: "this is a test error message"))
    }

    func testDecodeErrorPayloadWithMultipleErrors() async throws {
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

        let error = decoding.decodeError(from: json, httpCode: 400)
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        XCTAssertEqual(simpleMDMError, SimpleMDMError.generic(httpCode: 400, description: "this is the first test error message"))
    }
}
