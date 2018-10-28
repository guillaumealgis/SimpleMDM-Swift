//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class VersionTests: XCTestCase {
    func testVersionDecoding() {
        // JSONDecoder does not support decoding fragments yet, so we must wrap our version string in a JSON array.
        // See https://forums.swift.org/t/allowing-top-level-fragments-in-jsondecoder/11750/
        let data = Data("[\"4.54.16\"]".utf8)
        let decoder = JSONDecoder()

        do {
            let result = try decoder.decode([Version].self, from: data)
            guard let version = result.first else {
                return XCTFail("Unable to get first element of decoded array")
            }
            XCTAssertEqual(version.major, 4)
            XCTAssertEqual(version.minor, 54)
            XCTAssertEqual(version.patch, 16)
        } catch {
            XCTFail("Failed to decode Version: \(error)")
        }
    }

    func testInvalidVersionDecoding() {
        // JSONDecoder does not support decoding fragments yet, so we must wrap our version string in a JSON array.
        // See https://forums.swift.org/t/allowing-top-level-fragments-in-jsondecoder/11750/
        let data = Data("[\"4.54..16\"]".utf8)
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode([Version].self, from: data))
    }

    func testVersionEncoding() {
        let version = Version(major: 1, minor: 2, patch: 3)
        let encoder = JSONEncoder()

        do {
            // JSONEncoder does not support decoding fragments yet, so we must wrap our Version in an Array.
            // See https://forums.swift.org/t/allowing-top-level-fragments-in-jsondecoder/11750/
            let data = try encoder.encode([version])
            XCTAssertEqual(data, Data("[\"1.2.3\"]".utf8))
        } catch {
            XCTFail("Failed to encode Version: \(error)")
        }
    }

    func testVersionMemberwiseInitializer() {
        let version = Version(major: 4, minor: 2, patch: 7)
        XCTAssertEqual(version.major, 4)
        XCTAssertEqual(version.minor, 2)
        XCTAssertEqual(version.patch, 7)
    }

    func testVersionMemberwiseInitializerWithZeros() {
        let version = Version(major: 2, minor: 0, patch: 0)
        XCTAssertEqual(version.major, 2)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
    }

    func testVersionInitWithStringLiteralSimple() {
        guard let version = Version(string: "4.2.7") else {
            return XCTFail("Failed to parse version string")
        }
        XCTAssertEqual(version.major, 4)
        XCTAssertEqual(version.minor, 2)
        XCTAssertEqual(version.patch, 7)
    }

    func testVersionInitWithStringLiteralNoPatch() {
        guard let version = Version(string: "4.2") else {
            return XCTFail("Failed to parse version string")
        }
        XCTAssertEqual(version.major, 4)
        XCTAssertEqual(version.minor, 2)
        XCTAssertEqual(version.patch, 0)
    }

    func testVersionInitWithStringLiteralMultipleDots() {
        let version = Version(string: "4..2.7")
        XCTAssertNil(version)
    }

    func testVersionInitWithStringLiteralMoreThan3Parts() {
        let version = Version(string: "4.2.7.9")
        XCTAssertNil(version)
    }

    func testVersionInitWithStringLiteralLessThan2Parts() {
        let version = Version(string: "4")
        XCTAssertNil(version)
    }

    func testVersionInitWithStringLiteralBigNumbers() {
        guard let version = Version(string: "4238640239684.20867913510.95346097204567") else {
            return XCTFail("Failed to parse version string")
        }
        XCTAssertEqual(version.major, 4_238_640_239_684)
        XCTAssertEqual(version.minor, 20_867_913_510)
        XCTAssertEqual(version.patch, 95_346_097_204_567)
    }

    func testVersionInitWithStringLiteralWithZeros() {
        guard let version = Version(string: "0.3.1") else {
            return XCTFail("Failed to parse version string")
        }
        XCTAssertEqual(version.major, 0)
        XCTAssertEqual(version.minor, 3)
        XCTAssertEqual(version.patch, 1)
    }

    func testVersionInitWithStringLiteralLeadingZero() {
        guard let version = Version(string: "1.4.02") else {
            return XCTFail("Failed to parse version string")
        }
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 4)
        XCTAssertEqual(version.patch, 2)
    }

    func testVersionComparisons() {
        XCTAssertGreaterThan(Version(major: 1, minor: 0, patch: 0), Version(major: 0, minor: 9, patch: 9))
        XCTAssertGreaterThan(Version(major: 1, minor: 2, patch: 0), Version(major: 1, minor: 1, patch: 0))
        XCTAssertGreaterThan(Version(major: 1, minor: 1, patch: 2), Version(major: 1, minor: 1, patch: 1))
    }

    func testVersionComparisonsIrreflexivity() {
        XCTAssertFalse(Version(major: 1, minor: 0, patch: 0) < Version(major: 1, minor: 0, patch: 0))
    }

    func testVersionComparisonsAsymmetry() {
        let a = Version(major: 1, minor: 2, patch: 3)
        let b = Version(major: 1, minor: 5, patch: 0)
        XCTAssertLessThan(a, b) // If
        XCTAssertFalse(b < a) // Then
    }

    func testVersionComparisonsTransitivity() {
        let a = Version(major: 1, minor: 2, patch: 3)
        let b = Version(major: 1, minor: 5, patch: 0)
        let c = Version(major: 4, minor: 8, patch: 34)

        // If
        XCTAssertLessThan(a, b)
        XCTAssertLessThan(b, c)

        // Then
        XCTAssertLessThan(a, c)
    }

    func testVersionEquality() {
        XCTAssertEqual(Version(major: 5, minor: 43, patch: 25), Version(major: 5, minor: 43, patch: 25))
        XCTAssertEqual(Version(major: 1, minor: 7, patch: 0), Version(string: "1.7.0"))
    }
}
