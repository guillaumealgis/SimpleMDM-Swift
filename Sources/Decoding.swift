//
//  Copyright 2020 Guillaume Algis.
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
        decoder.dateDecodingStrategy = .custom(decodeSimpleMDMDate)
    }

    // MARK: - Decoding the response

    /// Decodes the data fetched from the API, and return the full payload of the HTTP response (i.e. everything in
    /// the JSON response).
    ///
    /// - Parameters:
    ///   - result: The request result to decode.
    ///   - expectedPayloadType: The expected payload type.
    /// - Returns: Either the decoded payload, or an error.
    func decodeNetworkingResultPayload<P: Payload>(_ result: NetworkingResult, expectedPayloadType: P.Type) -> Result<P> {
        switch result {
        case let .success(data):
            do {
                return .fulfilled(try decodePayload(ofType: expectedPayloadType, from: data))
            } catch {
                return .rejected(error)
            }
        case let .decodableDataFailure(httpCode, data):
            return .rejected(decodeError(from: data, httpCode: httpCode))
        case let .failure(error):
            return .rejected(error)
        }
    }

    /// Decodes the data fetched from the API, and return the data contained in the payload of the HTTP response
    /// (i.e. everything under the `"data"` key of the JSON response).
    ///
    /// - Parameters:
    ///   - result: The request result to decode.
    ///   - expectedPayloadType: The expected payload type.
    /// - Returns: Either the decoded data, or an error.
    func decodeNetworkingResult<P: Payload>(_ result: NetworkingResult, expectedPayloadType: P.Type) -> Result<P.DataType> {
        let payloadResult = decodeNetworkingResultPayload(result, expectedPayloadType: expectedPayloadType)
        switch payloadResult {
        case let .fulfilled(payload):
            return .fulfilled(payload.data)
        case let .rejected(error):
            return .rejected(error)
        }
    }

    private func decodePayload<P: Payload>(ofType type: P.Type, from data: Data) throws -> P {
        let payload = try decoder.decode(type.self, from: data)
        return payload
    }

    private func decodeError(from data: Data, httpCode: Int) -> Error {
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
