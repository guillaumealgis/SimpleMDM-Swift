//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

extension URL {
    /// Initializes a newly created URL referencing a list of resources.
    ///
    /// - Parameters:
    ///   - resourceType: The type of the resource.
    ///   - relativeTo: A base URL the new URL will be constructed uppon.
    init?<R: Resource>(resourceType: R.Type, relativeTo baseURL: URL) {
        self.init(string: resourceType.endpointName, relativeTo: baseURL)
    }

    /// Initializes a newly created URL referencing a resource with an identifier.
    ///
    /// - Parameters:
    ///   - resourceType: The type of the resource.
    ///   - id: The identifier of the resource.
    ///   - relativeTo: A base URL the new URL will be constructed uppon.
    init?<R: IdentifiableResource>(resourceType: R.Type, withId id: R.ID, relativeTo baseURL: URL) {
        let path = "\(resourceType.endpointName)/\(id)"
        self.init(string: path, relativeTo: baseURL)
    }

    // swiftlint:disable function_default_parameter_at_end

    /// Initializes a newly created URL referencing a paginated list of resources, optionally appending pagination
    /// parameters to the query part of the URL, and a search term.
    ///
    /// - Parameters:
    ///   - resourceType: The type of resource.
    ///   - matching: A string the fetched resources will match.
    ///   - startingAfter: The value for the 'startingAfter' parameter of the URL.
    ///   - limit: The value for the 'limit' parameter of the URL.
    ///   - relativeTo: A base URL the new URL will be constructed uppon.
    init?<R: ListableResource>(resourceType: R.Type, matching: String? = nil, startingAfter: R.ID? = nil, limit: Int? = nil, relativeTo baseURL: URL) {
        var urlComponents = URLComponents()

        var queryItems = [URLQueryItem]()
        if let matching = matching {
            queryItems.append(URLQueryItem(name: "search", value: matching))
        }
        if let startingAfter = startingAfter {
            queryItems.append(URLQueryItem(name: "starting_after", value: String(startingAfter)))
        }
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        urlComponents.queryItems = queryItems

        var url = resourceType.endpointName
        if let query = urlComponents.query, !query.isEmpty {
            url.append("?\(query)")
        }

        self.init(string: url, relativeTo: baseURL)
    }

    /// Initializes a newly created URL referencing a list of resources children of a parent resource.
    ///
    /// - Parameters:
    ///   - resourceType: The type of the children resources.
    ///   - parentType: The type of the parent resource.
    ///   - parentId: The identifier of the parent resource.
    ///   - relativeTo: A base URL the new URL will be constructed uppon.
    init?<R: IdentifiableResource, P: IdentifiableResource>(resourceType: R.Type, inParent parentType: P.Type, withId parentId: P.ID, relativeTo baseURL: URL) {
        let path = "\(parentType.endpointName)/\(parentId)/\(resourceType.endpointName)"
        self.init(string: path, relativeTo: baseURL)
    }

    /// Initializes a newly created URL referencing a paginated list of resources children of a parent resource,
    /// optionally appending pagination parameters to the query part of the URL.
    ///
    /// - Parameters:
    ///   - resourceType: The type of the children resources.
    ///   - parentType: The type of the parent resource.
    ///   - parentId: The identifier of the parent resource.
    ///   - startingAfter: The value for the 'startingAfter' parameter of the URL.
    ///   - limit: The value for the 'limit' parameter of the URL.
    ///   - relativeTo: A base URL the new URL will be constructed uppon.
    init?<R: ListableResource, P: IdentifiableResource>(resourceType: R.Type, inParent parentType: P.Type, withId parentId: P.ID, startingAfter: R.ID? = nil, limit: Int? = nil, relativeTo baseURL: URL) {
        guard let parentBaseURL = URL(string: "\(parentType.endpointName)/\(parentId)/", relativeTo: baseURL) else {
            return nil
        }
        self.init(resourceType: resourceType, startingAfter: startingAfter, limit: limit, relativeTo: parentBaseURL)
    }

    // swiftlint:enable function_default_parameter_at_end
}
