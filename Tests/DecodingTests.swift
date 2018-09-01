//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

class DecodingTests: XCTestCase {
    func testDecodeInvalidErrorPayload() {
        let json = """
          {
            "unexpected_field": [
              {
                "title": "this is a test error message",
              }
            ]
          }
        """.data(using: .utf8)!
        let decodingService = DecodingService()

        let error = decodingService.decodeError(from: json, httpCode: 400)
        guard let decodingError = error as? DecodingError else {
            return XCTFail("Expected error to be a DecodingError, got \(error)")
        }
        guard case let .keyNotFound(codingKey, _) = decodingError else {
            return XCTFail("Expected .keyNotFound, got \(decodingError)")
        }
        XCTAssertEqual(codingKey.stringValue, "errors")
    }

    func testDecodeErrorPayloadWithoutError() {
        let json = """
        {
          "errors": []
        }
        """.data(using: .utf8)!
        let decodingService = DecodingService()

        let error = decodingService.decodeError(from: json, httpCode: 400)
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        XCTAssertEqual(simpleMDMError, SimpleMDMError.unknown(httpCode: 400))
    }

    func testDecodeErrorPayload() {
        let json = """
          {
            "errors": [
              {
                "title": "this is a test error message"
              }
            ]
          }
        """.data(using: .utf8)!
        let decodingService = DecodingService()

        let error = decodingService.decodeError(from: json, httpCode: 400)
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        XCTAssertEqual(simpleMDMError, SimpleMDMError.generic(httpCode: 400, description: "this is a test error message"))
    }

    func testDecodeErrorPayloadWithMultipleErrors() {
        let json = """
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
        """.data(using: .utf8)!
        let decodingService = DecodingService()

        let error = decodingService.decodeError(from: json, httpCode: 400)
        guard let simpleMDMError = error as? SimpleMDMError else {
            return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
        }
        XCTAssertEqual(simpleMDMError, SimpleMDMError.generic(httpCode: 400, description: "this is the first test error message"))
    }
}
