//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A type defining a relation to one or more resources.
protocol RelatedToResource {}

/// A type for which the relation is defined by a decodable entry in the "relationships" part of the response payload.
protocol Relationship: RelatedToResource, Decodable {}

// MARK: - Relation

/// A type used to represent a relation to another resource.
///
/// - SeeAlso:
///   - `RelatedToOne`
///   - `RelatedToMany`
struct Relation<T: IdentifiableResource>: Decodable {
    /// The type name of the related object
    let type: String
    /// The identifier name of the related object
    let id: T.ID
}
