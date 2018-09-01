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
        XCTAssertTrue(error is DecodingError)
    }

    func testDecodeErrorPayloadWithoutError() {
        let json = """
        {
          "errors": []
        }
        """.data(using: .utf8)!
        let decodingService = DecodingService()

        let error = decodingService.decodeError(from: json, httpCode: 400)
        guard let apiError = error as? APIError else {
            return XCTFail("Expected error to be an APIError, got \(error)")
        }
        XCTAssertEqual(apiError, APIError.unknown(httpCode: 400))
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
        guard let apiError = error as? APIError else {
            return XCTFail("Expected error to be an APIError, got \(error)")
        }
        XCTAssertEqual(apiError, APIError.generic(httpCode: 400, description: "this is a test error message"))
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
        guard let apiError = error as? APIError else {
            return XCTFail("Expected error to be an APIError, got \(error)")
        }
        XCTAssertEqual(apiError, APIError.generic(httpCode: 400, description: "this is the first test error message"))
    }
}
