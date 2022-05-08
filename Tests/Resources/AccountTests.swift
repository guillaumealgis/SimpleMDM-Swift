//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class AccountTests: XCTestCase {
    func testGetAccount() async throws {
        let json = loadFixture("Account")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let account = try await Account.get()
        XCTAssertEqual(account.name, "MyCompany")
        XCTAssertEqual(account.appleStoreCountryCode, "US")
    }
}
