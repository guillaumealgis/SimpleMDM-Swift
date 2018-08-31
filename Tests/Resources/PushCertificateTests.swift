//
//  PushCertificateTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
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
