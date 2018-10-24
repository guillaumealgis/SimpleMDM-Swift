//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class CustomAttributeTests: XCTestCase {
    func testGetAllCustomAttributes() {
        let json = loadFixture("CustomAttributes")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        CustomAttribute.getAll(s.networking) { result in
            guard case let .success(customAttributes) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(customAttributes.count, 2)
        }
    }

    func testGetACustomAttribute() {
        let json = loadFixture("CustomAttribute_EmailAddress")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        CustomAttribute.get(s.networking, id: "email_address") { result in
            guard case let .success(customAttribute) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(customAttribute.name, "email_address")
        }
    }
}
