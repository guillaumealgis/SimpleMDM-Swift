//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A relation to another resource.
///
/// The related resource can be retrieved from the server using `get()`.
public struct RelatedToOne<Resource: GettableResource>: Relationship {
    private enum CodingKeys: String, CodingKey {
        case data
    }

    /// The underlying relation informations used to fetch the remote resource.
    private let relation: Relation<Resource>

    /// The identifier of the related resource.
    ///
    /// Accessing this property does not make a network request, so it can be used in some cases to optimize
    /// your application if you don't need the full related resource content.
    public var relatedId: Resource.ID {
        relation.id
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
        relation = try payload.decode(Relation.self, forKey: .data)
    }

    /// Fetch the related resource from the server.
    ///
    /// - Returns: The fetched resource.
    public func get() async throws -> Resource {
        try await Resource.get(id: relation.id)
    }
}
