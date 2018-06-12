//
//  ResultTypeTests.swift
//  Tests
//
//  Created by Guillaume Algis on 13/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import XCTest

@testable import SimpleMDM

class ResultTypeTests: XCTestCase {

    func testResultSuccessCanUnwrapValue() {
        let value = "Success !"
        let result = Result.success(value)

        XCTAssertEqual(result.value!, value)
    }

    func testResultSuccessCantUnwrapError() {
        let result = Result.success("Success !")

        XCTAssertNil(result.error)
    }

    func testResultFailureCanUnwrapError() {
        let error = NSError(domain: "com.example.errordomain", code: 42, userInfo: nil)
        let result = Result<Int>.failure(error)

        XCTAssertNotNil(result.error)
    }

    func testResultFailureCantUnwrapValue() {
        let error = NSError(domain: "com.example.errordomain", code: 42, userInfo: nil)
        let result = Result<Int>.failure(error)

        XCTAssertNil(result.value)
    }

}
