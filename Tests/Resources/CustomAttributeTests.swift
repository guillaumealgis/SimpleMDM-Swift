//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class CustomAttributeTests: XCTestCase {
    func testGetAllCustomAttributes() async throws {
        let json = loadFixture("CustomAttributes")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let customAttributes = try await CustomAttribute.all.collect()
        XCTAssertEqual(customAttributes.count, 2)
    }

    func testGetACustomAttribute() async throws {
        let json = loadFixture("CustomAttribute_EmailAddress")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let customAttribute = try await CustomAttribute.get(id: "email_address")
        XCTAssertEqual(customAttribute.name, "email_address")
    }
}
