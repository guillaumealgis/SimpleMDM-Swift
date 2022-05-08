//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

#warning("FIXME: Guillaume: Same implementation as AsyncResources, but with parendId. Do we need this ?")

/// A type defining an attribute of a resource having a "link" to its parent resource.
internal protocol NestedResourceAttribute {
    /// The type of the parent resource.
    associatedtype Parent: IdentifiableResource

    /// The identifier of the parent resource.
    var parentId: Parent.ID { get }
}

/// A special kind of relation to a group of remote resources, where the related resources are "children" resources of
/// another resource.
///
/// This is mostly a detail implementation of the SimpleMDM API. You can use this type of relation as if it was a
/// `RelatedToMany` relation for the most part. The only differences being that we do not know the related resources
/// ids ahead of time, so this object does not exposes a `relatedIds` property.
///
/// - SeeAlso: `RelatedToMany`
public struct RelatedToManyNested<Parent: IdentifiableResource, Resource: ListableResource>: RelatedToResource, NestedResourceAttribute, AsyncSequence {
    public typealias Element = Resource

    public struct AsyncIterator: AsyncIteratorProtocol {
        /// Whether the server has more resources available to be fetched.
        private var hasMore = true

        /// The identifier of the last resource of the last fetched page.
        private var lastFetchedId: Element.ID?

        /// The elements of the last fetched page that have not yet been returned by the `next()` method.
        private var lastFetchedResources: [Element] = []

        private let pageSize: Int
        private let parentId: Parent.ID

        init(parentId: Parent.ID, pageSize: Int) {
            self.parentId = parentId
            self.pageSize = pageSize
        }

        public mutating func next() async throws -> Element? {
            if lastFetchedResources.isEmpty {
                try await fetchNextPage()
            }

            let nextElement = lastFetchedResources.first
            if nextElement != nil {
                lastFetchedResources.removeFirst()
            }

            return nextElement
        }

        @discardableResult
        private mutating func fetchNextPage() async throws -> [Element] {
            guard pageSize >= PageLimit.min, pageSize <= PageLimit.max else {
                throw SimpleMDMError.invalidLimit(pageSize)
            }

            if pageSize <= lastFetchedResources.count {
                let elements = lastFetchedResources[0 ..< pageSize]
                lastFetchedResources.removeSubrange(0 ..< pageSize)
                return Array(elements)
            }

            // If necessary, complete the list of elements in `lastFetchedPageElements` with a fetch from the API.
            let fetchLimit = pageSize - lastFetchedResources.count
            if hasMore, fetchLimit > 0 {
                try await fetchNextPageOfResources(limit: fetchLimit)
            }

            return lastFetchedResources
        }

        private mutating func fetchNextPageOfResources(limit: Int) async throws {
            let payload = try await fetchAndDecodeNextPayload(limit: limit)
            let resources = payload.data
            guard !(payload.hasMore && resources.isEmpty) else {
                // We got an empty resource list, but the server advertised for more resources. That does not makes sense.
                throw SimpleMDMError.doesNotExpectMoreResources
            }
            if let lastResource = resources.last {
                lastFetchedId = lastResource.id
            }
            hasMore = payload.hasMore

            lastFetchedResources.append(contentsOf: resources)
        }

        private func fetchAndDecodeNextPayload(limit: Int) async throws -> PaginatedListPayload<Element> {
            let data = try await SimpleMDM.shared.networking.getDataForNestedListableResources(ofType: Resource.self, inParent: Parent.self, withId: parentId, startingAfter: lastFetchedId, limit: limit)
            let payload = try SimpleMDM.shared.decoding.decodePayload(ofType: PaginatedListPayload<Element>.self, from: data)
            return payload
        }
    }

    private let pageSize: Int

    let parentId: Parent.ID

    init(parentId: Parent.ID, pageSize: Int = PageLimit.max) {
        self.parentId = parentId
        self.pageSize = pageSize
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(parentId: parentId, pageSize: pageSize)
    }
}
