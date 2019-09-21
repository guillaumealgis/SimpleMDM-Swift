//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A struct representing a "semantic versioning" version number.
///
/// While this struct tries to follow the [SemVer 2.0.0](https://semver.org) as close as possible, it takes some
/// liberties for simplicity and convenience sake:
/// - String version numbers omitting a "patch" component are accepted, and their `patch` component defaults to `0`.
/// - "Pre-release" version numbers (with an hyphen after the patch component) are currently not supported.
public struct Version: Codable, Comparable, LosslessStringConvertible {
    /// The major version number of the release. Incremented when making incompatible API changes.
    let major: Int
    /// The minor version number of the release. Incremented when adding functionality in a backwards-compatible
    /// manner.
    let minor: Int
    /// The patch version number of the release. Incremented when making backwards-compatible bug fixes.
    let patch: Int

    /// A textual representation of this version number.
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }

    /// Memberwise initializer.
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    // MARK: - LosslessStringConvertible

    /// Instantiates a version number from a string representation.
    ///
    /// The string will be parsed and the expected formats are either:
    /// - "MAJOR.MINOR", or
    /// - "MAJOR.MINOR.PATCH"
    ///
    /// In the first case, the patch component of the version will default to `0`.
    ///
    /// If the parsed string is not in a valid format, the initializer will fail and return `nil`.
    ///
    /// - Parameter value: The formatted version number.
    public init?(_ description: String) {
        guard let (major, minor, patch) = Version.parseSemVerString(description) else {
            return nil
        }
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    // MARK: - Decodable

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data if not in the expected
    /// version number format.
    ///
    /// - Parameter decoder: The decoder to read data from.
    ///
    /// - SeeAlso: `init(string:)`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let (major, minor, patch) = Version.parseSemVerString(value) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid SemVer format")
        }
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    // MARK: - Encodable

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }

    // MARK: - Comparable

    /// Returns a Boolean value indicating whether the value of the first argument is less than that of the second
    /// argument.
    ///
    /// A version number is considered less than another version number if any of its components, starting from `major`
    /// and ending with `patch`, is less than same component of the other version number.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        return lhs.patch < rhs.patch
    }

    // MARK: - Equatable

    /// Returns a Boolean value indicating whether two version numbers are equal.
    ///
    /// Two version numbers are equal if all their components are equal.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }

    // MARK: - Version Parsing

    // swiftlint:disable:next large_tuple
    private static func parseSemVerString(_ value: String) -> (Int, Int, Int)? {
        let bits = value.split(separator: ".", omittingEmptySubsequences: false)
        guard bits.count == 2 || bits.count == 3 else {
            return nil
        }
        guard let major = parseSemVerSubstring(bits[0]) else {
            return nil
        }
        guard let minor = parseSemVerSubstring(bits[1]) else {
            return nil
        }
        let patch: Int
        if bits.count == 3 {
            guard let value = parseSemVerSubstring(bits[2]) else {
                return nil
            }
            patch = value
        } else {
            patch = 0
        }

        return (major, minor, patch)
    }

    private static func parseSemVerSubstring(_ substring: String.SubSequence) -> Int? {
        let string = String(substring)
        guard let number = Int(string) else {
            return nil
        }
        return number
    }
}
