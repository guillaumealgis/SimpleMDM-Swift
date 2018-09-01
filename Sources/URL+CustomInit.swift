//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

extension URL {
    init?<R: Resource>(resourceType: R.Type, relativeTo baseURL: URL) {
        self.init(string: resourceType.endpointName, relativeTo: baseURL)
    }

    init?<R: IdentifiableResource>(resourceType: R.Type, withId id: R.Identifier, relativeTo baseURL: URL) {
        let path = "\(resourceType.endpointName)/\(id)"
        self.init(string: path, relativeTo: baseURL)
    }

    init?<R: ListableResource>(resourceType: R.Type, startingAfter: R.Identifier? = nil, limit: Int? = nil, relativeTo baseURL: URL) {
        var urlComponents = URLComponents()

        var queryItems = [URLQueryItem]()
        if let startingAfter = startingAfter {
            queryItems.append(URLQueryItem(name: "starting_after", value: String(startingAfter)))
        }
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        urlComponents.queryItems = queryItems

        var url = resourceType.endpointName
        if let query = urlComponents.query {
            url.append("?\(query)")
        }

        self.init(string: url, relativeTo: baseURL)
    }
}
