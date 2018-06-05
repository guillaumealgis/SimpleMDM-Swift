//
//  APIKeyTests.swift
//  Tests
//
//  Created by Guillaume Algis on 04/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import XCTest

@testable import SimpleMDM

class APIKeyTests: XCTestCase {

    func testAPIKeyNotSetError() {
        let session = URLSessionMock()
        let networkController = NetworkController(urlSession: session)

        networkController.getUniqueResource(type: Account.self) { (result) in
            XCTAssertEqual(result.error! as! APIKeyError, APIKeyError.notSet)
        }
    }

}
