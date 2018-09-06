//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

class DecodingService {
    private let decoder = JSONDecoder()

    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom(decodeSimpleMDMDate)
    }

    // MARK: Decoding the response

    func decodeNetworkingResultPayload<P: Payload>(_ result: NetworkingResult, expectedPayloadType _: P.Type) -> Result<P> {
        switch result {
        case let .success(data):
            do {
                return .success(try decodePayload(ofType: P.self, from: data))
            } catch {
                return .failure(error)
            }
        case let .decodableDataFailure(httpCode, data):
            return .failure(decodeError(from: data, httpCode: httpCode))
        case let .failure(error):
            return .failure(error)
        }
    }

    func decodeNetworkingResult<P: Payload>(_ result: NetworkingResult, expectedPayloadType: P.Type) -> Result<P.DataType> {
        let payloadResult = decodeNetworkingResultPayload(result, expectedPayloadType: expectedPayloadType)
        switch payloadResult {
        case let .success(payload):
            return .success(payload.data)
        case let .failure(error):
            return .failure(error)
        }
    }

    private func decodePayload<P: Payload>(ofType type: P.Type, from data: Data) throws -> P {
        let payload = try decoder.decode(type.self, from: data)
        return payload
    }

    private func decodeError(from data: Data, httpCode: Int) -> Error {
        do {
            let payload = try decoder.decode(ErrorPayload.self, from: data)
            // We *may* get more than one error in the response data, but returning multiple error would make the
            // API much more complex so we only return the first one.
            if let firstError = payload.errors.first {
                return SimpleMDMError.generic(httpCode: httpCode, description: firstError.title)
            }
            return SimpleMDMError.unknown(httpCode: httpCode)
        } catch {
            return error
        }
    }
}
