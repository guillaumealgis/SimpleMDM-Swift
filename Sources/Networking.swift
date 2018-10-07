//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

internal enum NetworkingResult {
    case success(Data)
    case decodableDataFailure(httpCode: Int, data: Data)
    case failure(Error)
}

internal class Networking {
    var APIKey: String? {
        didSet {
            let utf8Data = APIKey?.data(using: .utf8)
            base64APIKey = utf8Data?.base64EncodedString()
        }
    }

    private var base64APIKey: String?
    // swiftlint:disable:next force_unwrapping
    private var baseURL = URL(string: "https://a.simplemdm.com/api/v1/")!
    private var session: URLSessionProtocol

    convenience init() {
        let session = URLSession(configuration: .default)
        self.init(urlSession: session)
    }

    init(urlSession: URLSessionProtocol) {
        session = urlSession
    }

    // MARK: Getting the resources

    internal func getDataForUniqueResource<R: UniqueResource>(ofType type: R.Type, completion: @escaping (NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    internal func getDataForResources<R: ListableResource>(ofType type: R.Type, startingAfter: R.Identifier? = nil, limit: Int? = nil, completion: @escaping (NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, startingAfter: startingAfter, limit: limit, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    internal func getDataForResource<R: IdentifiableResource>(ofType type: R.Type, withId id: R.Identifier, completion: @escaping (NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, withId: id, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    internal func getDataForNestedResources<R: IdentifiableResource, P: IdentifiableResource>(ofType type: R.Type, inParent parentType: P.Type, withId parentId: P.Identifier, completion: @escaping (_ result: NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, inParent: parentType, withId: parentId, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    internal func getDataForNestedListableResources<R: ListableResource, P: IdentifiableResource>(ofType type: R.Type, inParent parentType: P.Type, withId parentId: P.Identifier, startingAfter: R.Identifier? = nil, limit: Int? = nil, completion: @escaping (_ result: NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, inParent: parentType, withId: parentId, startingAfter: startingAfter, limit: limit, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    // MARK: Building the URLRequest

    private func buildURLRequest(withURL url: URL) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)

        guard let base64APIKey = base64APIKey else {
            throw SimpleMDMError.APIKeyNotSet
        }

        urlRequest.setValue("Basic \(base64APIKey)", forHTTPHeaderField: "Authorization")

        return urlRequest
    }

    // MARK: Making the request

    private func getData(atURL url: URL, completion: @escaping (NetworkingResult) -> Void) {
        let urlRequest: URLRequest
        do {
            urlRequest = try buildURLRequest(withURL: url)
        } catch {
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
            return .failure(SimpleMDMError.APIKeyInvalid)
        case 404:
            return .failure(SimpleMDMError.doesNotExist)
        default:
            return .decodableDataFailure(httpCode: httpResponse.statusCode, data: data)
        }
    }
}
