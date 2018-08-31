//
//  CustomAttributeTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

@testable import SimpleMDM
import XCTest

class CustomAttributeTests: XCTestCase {
    func testGetAllCustomAttributes() {
        let json = loadFixture("CustomAttributes")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomAttribute.getAll { result in
            guard case let .success(customAttributes) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(customAttributes.count, 2)
        }
    }

    func testGetACustomAttribute() {
        let json = loadFixture("CustomAttribute_EmailAddress")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        CustomAttribute.get(id: "email_address") { result in
            guard case let .success(customAttribute) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(customAttribute.name, "email_address")
        }
    }
}
