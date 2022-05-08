//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class PushCertificateTests: XCTestCase {
    func testGetPushCertificate() async throws {
        let json = loadFixture("PushCertificate")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let pushCertificate = try await PushCertificate.get()
        XCTAssertEqual(pushCertificate.appleId, "devops@example.org")
    }
}
