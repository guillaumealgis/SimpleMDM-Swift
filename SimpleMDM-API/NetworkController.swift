//
//  Network.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public typealias CompletionClosure<T> = (Result<T>) -> Void

public enum Result<T> {
    case success(T)
    case failure(Error)
}

internal class NetworkController {
    private let host = "a.simplemdm.com"
    private let endpoint = "api/v1/"

    private var baseURL: URL {
        return URL(string: "https://\(host)/\(endpoint)")!
    }

    private var session: URLSession!
    private let decoder = JSONDecoder()

    init() {
        session = URLSession(configuration: .default)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // MARK: Exposed API

    internal func getResource<T: Resource>(ofType type: T.Type, withId id: Int? = nil, atEndpoint endpoint: String, completion: @escaping CompletionClosure<T>) {
        getData(withId: id, atEndpoint: endpoint) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case let .success(httpCode, data):
                self.parseResponseData(data, forCode: httpCode, completion: completion)
            }
        }
    }

    // MARK: Getting the data from the server

    private func getData(withId id: Int? = nil, atEndpoint endpoint: String, completion: @escaping CompletionClosure<(Int, Data)>) {
        var url = baseURL.appendingPathComponent(endpoint)
        if let id = id {
            url.appendPathComponent(String(id))
        }

        var urlRequest = URLRequest(url: url)

        guard let base64APIKey = SimpleMDM.shared.base64APIKey else {
            completion(.failure(APIKeyError.notSet))
            return;
        }

        urlRequest.setValue("Basic \(base64APIKey)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                let error = error ?? NetworkError.unknown
                return completion(.failure(error))
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(NetworkError.noHTTPResponse))
            }

            guard httpResponse.statusCode != 401 else {
                return completion(.failure(APIKeyError.invalid))
            }

            guard let mimeType = httpResponse.mimeType, mimeType == "application/json" else {
                return completion(.failure(NetworkError.unexpectedMimeType(httpResponse.mimeType)))
            }

            completion(.success((httpResponse.statusCode, data)))
        }
        task.resume()
    }

    // MARK: Handling the HTTP response code and data

    private func parseResponseData<T: Resource>(_ data: Data, forCode httpCode: Int, completion: @escaping CompletionClosure<T>) {
        switch httpCode {
        case 200:
            decodeAndReturnResource(data, completion: completion)
        case 404:
            completion(.failure(APIError.doesNotExist))
        default:
            decodeAndReturnError(code: httpCode, from: data, completion: completion)
        }
    }

    // MARK: Data decoding

    private func decodeAndReturnResource<T: Resource>(_ data: Data, completion: @escaping CompletionClosure<T>) {
        let payload: Payload<T>
        let result: Result<T>
        do {
            payload = try self.decoder.decode(Payload<T>.self, from: data)
            result = .success(payload.data.attributes)
        }
        catch {
            result = .failure(error)
        }

        completion(result)
    }

    private func decodeAndReturnError<T: Resource>(code: Int, from data: Data, completion: @escaping CompletionClosure<T>) {
        let payload: ErrorPayload
        let result: Result<T>
        do {
            payload = try self.decoder.decode(ErrorPayload.self, from: data)
            result = .failure(APIError.generic(code: code, description: payload.title))
        }
        catch {
            result = .failure(error)
        }

        completion(result)
    }
}
