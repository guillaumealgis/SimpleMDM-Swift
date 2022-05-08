//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// The decoding layer of the library. Use this class to decode data received from the `Networking` class.
///
/// This decodes data in the JSON format.
internal class Decoding {
    private let decoder = JSONDecoder()

    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom(decodeRFC3339Date)
    }

    // MARK: - Decoding dates

    private func decodeRFC3339Date(decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date is not of expected RFC3339 format '5.6. Internet Date/Time' (with milliseconds)")
    }

    // MARK: - Decoding the response

    /// Decodes the data fetched from the API, and returns the "content" (i.e. everything under the `"data"` key of the
    /// JSON response) contained in the payload of the HTTP response
    /// , as objects.
    ///
    /// - Parameters:
    ///   - payloadType: The expected payload type.
    ///   - data: The bytes of the HTTP response's body.
    ///
    /// - Returns: The decoded object(s).
    func decodeContent<P: Payload>(containedInPayloadOfType payloadType: P.Type, from data: Data) throws -> P.DataType {
        let payload = try decodePayload(ofType: payloadType, from: data)
        return payload.data
    }

    /// Decodes a non-error payload from the API.
    ///
    /// - Parameters:
    ///   - payloadType: The expected payload type.
    ///   - data: The bytes of the HTTP response's body.
    ///
    /// - Returns: The decoded full JSON payload.
    func decodePayload<P: Payload>(ofType payloadType: P.Type, from data: Data) throws -> P {
        let payload = try decoder.decode(payloadType.self, from: data)
        return payload
    }

    /// Decodes an error payload from the API (i.e. a JSON document with a `"errors"` key), and returns it as a
    /// throwable Swift Error.
    ///
    /// - Parameters:
    ///   - data: The bytes of the HTTP response's body.
    ///   - httpCode: The status code of the HTTP response.
    ///
    /// - Returns: The error decoded from the JSON payload.
    func decodeError(from data: Data, httpCode: Int) -> Error {
        let payload: ErrorPayload
        do {
            payload = try decoder.decode(ErrorPayload.self, from: data)
        } catch DecodingError.dataCorrupted {
            return SimpleMDMError.unknown(httpCode: httpCode)
        } catch {
            return error
        }

        // We *may* get more than one error in the response data, but returning multiple error would make the
        // API much more complex so we only return the first one.
        if let firstError = payload.errors.first {
            return SimpleMDMError.generic(httpCode: httpCode, description: firstError.title)
        }
        return SimpleMDMError.unknown(httpCode: httpCode)
    }
}
