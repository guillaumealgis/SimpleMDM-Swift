//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

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
