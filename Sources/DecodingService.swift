//
//  DecodingService.swift
//  SimpleMDM
//
//  Created by Guillaume Algis on 09/08/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

internal class DecodingService {
    private let decoder = JSONDecoder()

    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom(decodeSimpleMDMDate)
    }

    // MARK: Decoding the response

    func decodePayload<P: Payload>(ofType type: P.Type, from data: Data) throws -> P.DataType {
        let payload = try decoder.decode(type.self, from: data)
        return payload.data
    }

    func decodeError(from data: Data, httpCode: Int) -> Error {
        do {
            let payload = try decoder.decode(ErrorPayload.self, from: data)
            // We *may* get more than one error in the response data, but returning multiple error would make the
            // API much more complex so we only return the first one.
            if let firstError = payload.errors.first {
                return APIError.generic(httpCode: httpCode, description: firstError.title)
            }
            return APIError.unknown(httpCode: httpCode)
        } catch {
            return error
        }
    }
}
