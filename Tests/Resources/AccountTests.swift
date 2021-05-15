//
//  Copyright 2021 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class AccountTests: XCTestCase {
    func testGetAccount() {
        let json = loadFixture("Account")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        let expectation = self.expectation(description: "Callback called")

        Account.get(s.networking) { result in
            guard case let .fulfilled(account) = result else {
                return XCTFail("Expected .fulfilled, got \(result)")
            }
            XCTAssertEqual(account.name, "MyCompany")
            XCTAssertEqual(account.appleStoreCountryCode, "US")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
