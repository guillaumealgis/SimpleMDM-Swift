//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A custom date decoding strategy used when decoding dates in the SimpleMDM API JSON responses.
///
/// This is needed because for some dates SimpleMDM uses a standard RFC 3339 date format, but for others they chose to
/// use another custom format. The startegy is simply to try both format, and throw a `DecodingError` if we could not
/// get a valid date with any of them.
///
/// See also [Keith Harrison's blog on custom date decoding](https://useyourloaf.com/blog/swift-codable-with-custom-dates/).
///
/// - Parameter decoder: The decoder to read data from.
/// - Returns: The decoded date.
/// - Throws: An error of type `DecodingError`.
/// - SeeAlso: `DateFormatter.simpleMDMFormat`.
internal func decodeSimpleMDMDate(decoder: Decoder) throws -> Date {
    let container = try decoder.singleValueContainer()
    let dateString = try container.decode(String.self)

    // Try the custom SimpleMDM format first, as it's the one used most often
    if let date = DateFormatter.simpleMDMFormat.date(from: dateString) {
        return date
    }

    // Sometimes though, the SimpleMDM API uses the RFC 3339 format
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    if let date = formatter.date(from: dateString) {
        return date
    }

    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date string does not match any expected format")
}
