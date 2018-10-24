//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class PushCertificateTests: XCTestCase {
    func testGetPushCertificate() {
        let json = loadFixture("PushCertificate")
        let session = URLSessionMock(data: json, responseCode: 200)
        let s = SimpleMDM(sessionMock: session)

        PushCertificate.get(s.networking) { result in
            guard case let .success(pushCertificate) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(pushCertificate.appleId, "devops@example.org")
        }
    }
}
