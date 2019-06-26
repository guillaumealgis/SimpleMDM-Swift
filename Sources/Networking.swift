//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A result type repsenting a HTTP connection response. Used as a return type by the methods in the `Networking`
/// class.
///
/// *Values*
/// - `succes` The request was successful. The associated value contains the HTTP body data.
/// - `decodableDataFailure` The HTTP request returned a non-success (200) code. The associated values are the HTTP
///   code returned by the server, and the HTTP body data (that should be possible to decode).
/// - `failure` The HTTP request failed, probably due to a connection error.
internal enum NetworkingResult {
    case success(Data)
    case decodableDataFailure(httpCode: Int, data: Data)
    case failure(Error)
}

/// The netwoking layer of the library. Use this class to send HTTP requests to the SimpleMDM server.
///
/// - Note: You should not instanciate this class directly, but instead use the global instance `SimpleMDM.networking`.
///   This allows the library to re-use a single connection, improving performances.
internal class Networking {
    var apiKey: String? {
        didSet {
            let utf8Data = apiKey?.data(using: .utf8)
            base64APIKey = utf8Data?.base64EncodedString()
        }
    }

    /// A base64 representation of `apiKey`.
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

    // MARK: - Getting the resources

    /// Make a HTTP request for a `UniqueResouce`.
    ///
    /// - Parameters:
    ///   - type: The type of the unique resource you want to fetch.
    ///   - completion: A completion handler called with the result of the HTTP request, or an error.
    ///   - result: The result of the network operation. See `NetworkingResult`.
    internal func getDataForUniqueResource<R: UniqueResource>(ofType type: R.Type, completion: @escaping (_ result: NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    /// Make a HTTP request for a `ListableResource`.
    ///
    /// - Parameters:
    ///   - ofType: The type of the resources you want to fetch.
    ///   - startingAfter: The id of a resource. The fetched list of resources will start after (and not including)
    ///     this resource. It is typically set to the id of the last object of the previous response. If unspecified,
    ///     the returned list will start at the beginning of the complete resources list.
    ///   - limit: A limit on the number of resources to be returned, between `CursorLimit.min` and `CursorLimit.max`.
    ///     See SimpleMDM's online documentation for the default value (`10` at the time of writing).
    ///   - completion: A completion handler called with the result of the HTTP request, or an error.
    ///   - result: The result of the network operation. See `NetworkingResult`.
    internal func getDataForResources<R: ListableResource>(ofType type: R.Type, startingAfter: R.Identifier? = nil, limit: Int? = nil, completion: @escaping (_ result: NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, startingAfter: startingAfter, limit: limit, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    /// Make a HTTP request for a `SearchableResource`.
    ///
    /// - Parameters:
    ///   - ofType: The type of the resources you want to fetch.
    ///   - matching: A string the fetched resources will match.
    ///   - startingAfter: The id of a resource. The fetched list of resources will start after (and not including)
    ///     this resource. It is typically set to the id of the last object of the previous response. If unspecified,
    ///     the returned list will start at the beginning of the complete resources list.
    ///   - limit: A limit on the number of resources to be returned, between `CursorLimit.min` and `CursorLimit.max`.
    ///     See SimpleMDM's online documentation for the default value (`10` at the time of writing).
    ///   - completion: A completion handler called with the result of the HTTP request, or an error.
    ///   - result: The result of the network operation. See `NetworkingResult`.
    internal func getDataForResources<R: SearchableResource>(ofType type: R.Type, matching: String, startingAfter: R.Identifier? = nil, limit: Int? = nil, completion: @escaping (_ result: NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, matching: matching, startingAfter: startingAfter, limit: limit, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    /// Make a HTTP request for a `ListableResource`.
    ///
    /// - Parameters:
    ///   - ofType: The type of the resource you want to fetch.
    ///   - id: The id of the resource you want to fetch.
    ///   - completion: A completion handler called with the result of the HTTP request, or an error.
    ///   - result: The result of the network operation. See `NetworkingResult`.
    internal func getDataForResource<R: IdentifiableResource>(ofType type: R.Type, withId id: R.Identifier, completion: @escaping (_ result: NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, withId: id, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    /// Make a HTTP request for a list of nested resource. Nested resources are "children" resources of a parent, with
    /// their endpoint being of the form `https://api.simplemdm.com/<parent_type>/<parent_id>/<nested_type>/`.
    ///
    /// - Parameters:
    ///   - ofType: The type of the (nested) resource you want to fetch.
    ///   - parentType: The type of the parent resource.
    ///   - parentId: The id of the parent resource.
    ///   - completion: A completion handler called with the result of the HTTP request, or an error.
    ///   - result: The result of the network operation. See `NetworkingResult`.
    ///
    /// - SeeAlso:
    ///   - `Device.CustomAttributeValue`
    ///   - `App.ManagedConfig`
    internal func getDataForNestedResources<R: IdentifiableResource, P: IdentifiableResource>(ofType type: R.Type, inParent parentType: P.Type, withId parentId: P.Identifier, completion: @escaping (_ result: NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, inParent: parentType, withId: parentId, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    /// Make a HTTP request for a paginated list of nested resource. While similar to
    /// `getDataForNestedListableResources(ofType:inParent:withId:startingAfter:limit:completion:)`, this method
    /// should be used to retrieve list of resources conforming to the `ListableResource` protocol.
    ///
    /// - Parameters:
    ///   - ofType: The type of the (nested) resource you want to fetch.
    ///   - parentType: The type of the parent resource.
    ///   - parentId: The id of the parent resource.
    ///   - startingAfter: The id of a resource. The fetched list of resources will start after (and not including)
    ///     this resource. It is typically set to the id of the last object of the previous response. If unspecified,
    ///     the returned list will start at the beginning of the complete resources list.
    ///   - limit: A limit on the number of resources to be returned, between `CursorLimit.min` and `CursorLimit.max`.
    ///     See SimpleMDM's online documentation for the default value (`10` at the time of writing).
    ///   - completion: A completion handler called with the result of the HTTP request, or an error.
    ///   - result: The result of the network operation. See `NetworkingResult`.
    ///
    /// - SeeAlso:
    ///   - `getDataForNestedResources:ofType:inParent:withId:completion`
    internal func getDataForNestedListableResources<R: ListableResource, P: IdentifiableResource>(ofType type: R.Type, inParent parentType: P.Type, withId parentId: P.Identifier, startingAfter: R.Identifier? = nil, limit: Int? = nil, completion: @escaping (_ result: NetworkingResult) -> Void) {
        guard let url = URL(resourceType: type, inParent: parentType, withId: parentId, startingAfter: startingAfter, limit: limit, relativeTo: baseURL) else {
            completion(.failure(InternalError.malformedURL))
            return
        }
        getData(atURL: url, completion: completion)
    }

    // MARK: - Building the URLRequest

    private func buildURLRequest(withURL url: URL) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)

        guard let base64APIKey = base64APIKey else {
            throw SimpleMDMError.apiKeyNotSet
        }

        urlRequest.setValue("Basic \(base64APIKey)", forHTTPHeaderField: "Authorization")

        return urlRequest
    }

    // MARK: - Making the request

    private func getData(atURL url: URL, completion: @escaping (_ result: NetworkingResult) -> Void) {
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
            return .failure(SimpleMDMError.apiKeyInvalid)
        case 404:
            return .failure(SimpleMDMError.doesNotExist)
        default:
            return .decodableDataFailure(httpCode: httpResponse.statusCode, data: data)
        }
    }
}
