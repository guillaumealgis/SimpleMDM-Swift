//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

@testable import SimpleMDM

/// An empty unique resource used when testing.
internal struct UniqueResourceMock: UniqueResource {
    static let endpointName = "unique_resource_mock"

    private enum CodingKeys: String, CodingKey {
        case type
        case attributes
    }

    init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "unique_resource_mock")
    }
}

/// An empty listable resource used when testing.
internal struct ResourceMock: ListableResource {
    typealias ID = Int

    static let endpointName = "resource_mock"

    let id: ID

    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
    }

    init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(ID.self, forKey: .id)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "resource_mock")
    }
}

/// An listable resource with a field of type `Date` used when testing.
internal struct ResourceWithDateMock: ListableResource {
    typealias ID = Int

    static let endpointName = "resource_with_date_mock"

    let id: ID
    let date: Date

    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
    }

    private enum AttributesKeys: String, CodingKey {
        case date
    }

    init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(ID.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        date = try attributes.decode(Date.self, forKey: .date)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "resource_with_date_mock")
    }
}

/// An listable resource with fields of type `RelatedToOne`, `RelatedToMany`, and `RelatedToManyNested` used when testing.
internal struct ResourceWithRelationsMock: ListableResource {
    typealias ID = Int

    static let endpointName = "resource_with_relations_mock"

    let id: ID
    let toOne: RelatedToOne<ResourceMock>
    let toMany: RelatedToMany<ResourceMock>
    let toManyNested: RelatedToManyNested<ResourceWithRelationsMock, ResourceMock>

    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
        case relationships
    }

    private enum RelationshipKeys: String, CodingKey {
        case toOne
        case toMany
    }

    init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(ID.self, forKey: .id)

        let relationships = try payload.nestedContainer(keyedBy: RelationshipKeys.self, forKey: .relationships)
        toOne = try relationships.decode(RelatedToOne<ResourceMock>.self, forKey: .toOne)
        toMany = try relationships.decode(RelatedToMany<ResourceMock>.self, forKey: .toMany)
        toManyNested = RelatedToManyNested<ResourceWithRelationsMock, ResourceMock>(parentId: id)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "resource_with_relations_mock")
    }
}
