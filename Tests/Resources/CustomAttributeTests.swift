//
//  Copyright 2020 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class CustomAttributeTests: XCTestCase {
    func testGetAllCustomAttributes() {
        let json = loadFixture("CustomAttributes")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        CustomAttribute.getAll(s.networking) { result in
            guard case let .fulfilled(customAttributes) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(customAttributes.count, 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetACustomAttribute() {
        let json = loadFixture("CustomAttribute_EmailAddress")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        CustomAttribute.get(s.networking, id: "email_address") { result in
            guard case let .fulfilled(customAttribute) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(customAttribute.name, "email_address")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
