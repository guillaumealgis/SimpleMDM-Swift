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

    var value: T? {
        switch self {
        case .success(let value):
            return value
        default:
            return nil
        }
    }
    var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}

internal class NetworkController {
    internal var APIKey: String? {
        didSet {
            let utf8Data = APIKey?.data(using: .utf8)
            base64APIKey = utf8Data?.base64EncodedString()
        }
    }
    private var base64APIKey: String?

    private let host = "a.simplemdm.com"
    private let endpoint = "api/v1/"

    private var baseURL: URL {
        return URL(string: "https://\(host)/\(endpoint)")!
    }

    private var session: URLSessionProtocol!
    private let decoder = JSONDecoder()

    convenience init() {
        let session = URLSession(configuration: .default)
        self.init(urlSession: session)
    }

    init(urlSession: URLSessionProtocol) {
        session = urlSession
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(DateFormatter.simpleMDMFormat)
    }

    // MARK: Getting the resources

    internal func getUniqueResource<R: UniqueResource>(type: R.Type, completion: @escaping CompletionClosure<R>) {
        let url = buildURL(for: type)
        getPayloadData(from: SimplePayload<R>.self, atURL: url, completion: completion)
    }

    internal func getResource<R: Resource>(type: R.Type, withId id: Int, completion: @escaping CompletionClosure<R>) {
        let url = buildURL(for: type, withId: id)
        getPayloadData(from: SimplePayload<R>.self, atURL: url, completion: completion)
    }

    internal func getAllResources<R: Resource>(type: R.Type, completion: @escaping CompletionClosure<[R]>) {
        let url = buildURL(for: type)
        getPayloadData(from: ListPayload<R>.self, atURL: url, completion: completion)
    }

    // MARK: Making the request

    private func getPayloadData<PayloadType: Payload>(from payloadType: PayloadType.Type, atURL url: URL, completion: @escaping CompletionClosure<PayloadType.ResourceType>) {
        makeRequest(with: url) { (fetchResult) in
            guard case let .success(code, data) = fetchResult else {
                completion(.failure(fetchResult.error!))
                return
            }

            do {
                let payload: PayloadType = try self.handleResponse(code: code, data: data)
                let resource = payload.extractResource()
                completion(.success(resource))
            }
            catch {
                completion(.failure(error))
            }
        }
    }

    private func buildURL(for type: GenericResource.Type, withId id: Int? = nil) -> URL {
        var url = baseURL.appendingPathComponent(type.endpointName)
        if let id = id {
            url.appendPathComponent(String(id))
        }
        return url
    }

    private func makeRequest(with url: URL, completion: @escaping CompletionClosure<(Int, Data)>) {
        var urlRequest = URLRequest(url: url)

        guard let base64APIKey = base64APIKey else {
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

            guard let mimeType = httpResponse.mimeType, mimeType == "application/json" else {
                return completion(.failure(NetworkError.unexpectedMimeType(httpResponse.mimeType)))
            }

            completion(.success((httpResponse.statusCode, data)))
        }
        task.resume()
    }

    private func handleResponse<PayloadType: Payload>(code: Int, data: Data) throws -> PayloadType {
        switch code {
        case 200:
            return try decodePayload(from: data)
        case 401:
            throw APIKeyError.invalid
        case 404:
            throw APIError.doesNotExist
        default:
            throw decodeError(from: data, code: code)
        }
    }

    // MARK: Decoding the response

    private func decodePayload<PayloadType: Payload>(from data: Data) throws -> PayloadType {
        let payload = try self.decoder.decode(PayloadType.self, from: data)
        return payload
    }

    private func decodeError(from data: Data, code: Int) -> Error {
        do {
            let payload = try self.decoder.decode(ErrorPayload.self, from: data)
            // We *may* get more than one error in the response data, but returning multiple error would make the
            // API much more complex so we only return the first one.
            if let firstError = payload.errors.first {
                return APIError.generic(code: code, description: firstError.title)
            }
            return APIError.unknown(code: code)
        }
        catch {
            return error
        }
    }
}
