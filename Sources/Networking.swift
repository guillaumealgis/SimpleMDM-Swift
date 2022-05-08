//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// The networking layer of the library. Use this class to send HTTP requests to the SimpleMDM server.
///
/// - Note: You should not instantiate this class directly, but instead use the global instance `SimpleMDM.networking`.
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

    /// Make a HTTP request for a `UniqueResource`.
    ///
    /// - Parameters:
    ///   - type: The type of the unique resource you want to fetch.
    ///
    /// - Returns: The raw data of the HTTP response's body.
    internal func getDataForUniqueResource<R: UniqueResource>(ofType type: R.Type) async throws -> Data {
        guard let url = URL(resourceType: type, relativeTo: baseURL) else {
            throw InternalError.malformedURL
        }
        let data = try await getData(atURL: url)
        return data
    }

    /// Make a HTTP request for a `FetchableListableResource`.
    ///
    /// - Parameters:
    ///   - ofType: The type of the resources you want to fetch.
    ///   - startingAfter: The id of a resource. The fetched list of resources will start after (and not including)
    ///     this resource. It is typically set to the id of the last object of the previous response. If unspecified,
    ///     the returned list will start at the beginning of the complete resources list.
    ///   - limit: A limit on the number of resources to be returned, between `PageLimit.min` and `PageLimit.max`.
    ///
    /// - Returns: The raw data of the HTTP response's body.
    internal func getDataForResources<R: FetchableListableResource>(ofType type: R.Type, startingAfter: R.ID? = nil, limit: Int? = nil) async throws -> Data {
        guard let url = URL(resourceType: type, startingAfter: startingAfter, limit: limit, relativeTo: baseURL) else {
            throw InternalError.malformedURL
        }
        let data = try await getData(atURL: url)
        return data
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
    ///
    /// - Returns: The raw data of the HTTP response's body.
    internal func getDataForResources<R: SearchableResource>(ofType type: R.Type, matching: String, startingAfter: R.ID? = nil, limit: Int? = nil) async throws -> Data {
        guard let url = URL(resourceType: type, matching: matching, startingAfter: startingAfter, limit: limit, relativeTo: baseURL) else {
            throw InternalError.malformedURL
        }
        let data = try await getData(atURL: url)
        return data
    }

    /// Make a HTTP request for a `ListableResource`.
    ///
    /// - Parameters:
    ///   - ofType: The type of the resource you want to fetch.
    ///   - id: The id of the resource you want to fetch.
    ///
    /// - Returns: The raw data of the HTTP response's body.
    internal func getDataForResource<R: IdentifiableResource>(ofType type: R.Type, withId id: R.ID) async throws -> Data {
        guard let url = URL(resourceType: type, withId: id, relativeTo: baseURL) else {
            throw InternalError.malformedURL
        }
        let data = try await getData(atURL: url)
        return data
    }

    /// Make a HTTP request for a list of nested resource. Nested resources are "children" resources of a parent, with
    /// their endpoint being of the form `https://api.simplemdm.com/<parent_type>/<parent_id>/<nested_type>/`.
    ///
    /// - Parameters:
    ///   - ofType: The type of the (nested) resource you want to fetch.
    ///   - parentType: The type of the parent resource.
    ///   - parentId: The id of the parent resource.
    ///
    /// - Returns: The bytes of the HTTP response's body.
    ///
    /// - SeeAlso:
    ///   - `Device.CustomAttributeValue`
    ///   - `App.ManagedConfig`
    internal func getDataForNestedResources<R: ListableResource, P: IdentifiableResource>(ofType type: R.Type, inParent parentType: P.Type, withId parentId: P.ID) async throws -> Data {
        guard let url = URL(resourceType: type, inParent: parentType, withId: parentId, relativeTo: baseURL) else {
            throw InternalError.malformedURL
        }
        let data = try await getData(atURL: url)
        return data
    }

    /// Make a HTTP request for a paginated list of nested resource. While similar to
    /// `getDataForNestedResources(ofType:inParent:withId:)`, this method should be used to retrieve list of resources
    /// conforming to the `ListableResource` protocol.
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
    ///
    /// - Returns: The bytes of the HTTP response's body.
    ///
    /// - SeeAlso:
    ///   - `getDataForNestedResources:ofType:inParent:withId:`
    internal func getDataForNestedListableResources<R: ListableResource, P: IdentifiableResource>(ofType type: R.Type, inParent parentType: P.Type, withId parentId: P.ID, startingAfter: R.ID? = nil, limit: Int? = nil) async throws -> Data {
        guard let url = URL(resourceType: type, inParent: parentType, withId: parentId, startingAfter: startingAfter, limit: limit, relativeTo: baseURL) else {
            throw InternalError.malformedURL
        }
        let data = try await getData(atURL: url)
        return data
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

    private func getData(atURL url: URL) async throws -> Data {
        let urlRequest = try buildURLRequest(withURL: url)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noHTTPResponse
        }

        guard let mimeType = httpResponse.mimeType, mimeType == "application/json" else {
            throw NetworkError.unexpectedMimeType(httpResponse.mimeType)
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw SimpleMDMError.apiKeyInvalid
        case 404:
            throw SimpleMDMError.doesNotExist
        default:
            let error = SimpleMDM.shared.decoding.decodeError(from: data, httpCode: httpResponse.statusCode)
            throw error
        }

        return data
    }
}
