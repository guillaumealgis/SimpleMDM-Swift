//
//  Network.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

internal enum NetworkingResult {
    case success(Data)
    case decodableDataFailure(httpCode: Int, data: Data)
    case failure(Error)
}

internal class NetworkingService {
    var APIKey: String? {
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

    convenience init() {
        let session = URLSession(configuration: .default)
        self.init(urlSession: session)
    }

    init(urlSession: URLSessionProtocol) {
        session = urlSession
    }

    // MARK: Getting the resources

    internal func getDataForAllResources<R: Resource>(ofType type: R.Type, completion: @escaping (NetworkingResult) -> Void) {
        let url = buildURL(for: type)
        getData(atURL: url, completion: completion)
    }

    internal func getDataForSingleResource<R: IdentifiableResource>(ofType type: R.Type, withId id: R.Identifier, completion: @escaping (NetworkingResult) -> Void) {
        let url = buildURL(for: type, withId: id)
        getData(atURL: url, completion: completion)
    }

    // MARK: Building the URL

    private func buildURL(for type: Resource.Type) -> URL {
        let url = baseURL.appendingPathComponent(type.endpointName)
        return url
    }

    private func buildURL<T: LosslessStringConvertible>(for type: Resource.Type, withId id: T) -> URL {
        var url = buildURL(for: type)
        url.appendPathComponent(String(id))
        return url
    }

    private func buildURLRequest(withURL url: URL) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)

        guard let base64APIKey = base64APIKey else {
            throw APIKeyError.notSet
        }

        urlRequest.setValue("Basic \(base64APIKey)", forHTTPHeaderField: "Authorization")

        return urlRequest
    }

    // MARK: Making the request

    private func getData(atURL url: URL, completion: @escaping (NetworkingResult) -> Void) {
        let urlRequest: URLRequest
        do {
            urlRequest = try buildURLRequest(withURL: url)
        } catch let error {
            return completion(.failure(error))
        }

        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                let error = error ?? NetworkError.unknown
                return completion(.failure(error))
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(NetworkError.noHTTPResponse))
            }

            let result = self.handleResponse(httpResponse, data: data)
            completion(result)
        }
        task.resume()
    }

    private func handleResponse(_ httpResponse: HTTPURLResponse, data: Data) -> NetworkingResult {
        guard let mimeType = httpResponse.mimeType, mimeType == "application/json" else {
            return .failure(NetworkError.unexpectedMimeType(httpResponse.mimeType))
        }

        switch httpResponse.statusCode {
        case 200:
            return .success(data)
        case 401:
            return .failure(APIKeyError.invalid)
        case 404:
            return .failure(APIError.doesNotExist)
        default:
            return .decodableDataFailure(httpCode: httpResponse.statusCode, data: data)
        }
    }
}
