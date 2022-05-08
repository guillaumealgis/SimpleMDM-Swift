//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A relation to a group of remote resources.
///
/// The related resources can be retrieved from the server either by id, by index, or by fetching the entire collection.
public struct RelatedToMany<Element: GettableResource>: Relationship, AsyncSequence {
    private enum CodingKeys: String, CodingKey {
        case data
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private let relations: [Relation<Element>]
        private var nextIndex = 0

        init(relations: [Relation<Element>]) {
            self.relations = relations
        }

        public mutating func next() async throws -> Element? {
            guard nextIndex < relations.count else {
                return nil
            }

            let resource = try await Element.get(id: relations[nextIndex].id)
            nextIndex += 1
            return resource
        }
    }

    /// The underlying relations informations used to fetch the remote resources.
    private let relations: [Relation<Element>]

    /// The identifiers of the related resources.
    ///
    /// Accessing this property does not make a network request, so it can be used in some cases to optimize
    /// your application if you don't need the full related resources content.
    public var relatedIds: [Element.ID] {
        relations.map(\.id)
    }

    public var count: Int {
        relations.count
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)
        relations = try payload.decode([Relation].self, forKey: .data)
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(relations: relations)
    }

    /// Fetch the related resource at `index` in the collection from the server.
    ///
    /// - Parameters:
    ///   - index: The index of the resource to fetch in the collection.
    ///
    /// - Returns: The fetched resource.
    public subscript(index: Int) -> Element {
        get async throws {
            try await Element.get(id: relations[index].id)
        }
    }

    /// Fetch the related resource with the identifier `id` in the collection from the server.
    ///
    /// - Parameters:
    ///   - index: The index of the resource to fetch in the collection.
    ///
    /// - Returns: The fetched resource.
    public subscript(id id: Element.ID) -> Element {
        get async throws {
            try await Element.get(id: id)
        }
    }
}
