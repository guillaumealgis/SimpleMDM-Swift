//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

class PushCertificateTests: XCTestCase {
    func testGetPushCertificate() {
        let json = loadFixture("PushCertificate")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        PushCertificate.get { result in
            guard case let .success(pushCertificate) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(pushCertificate.appleId, "devops@example.org")
        }
    }
}
