//
//  Copyright 2018 Guillaume Algis.
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
    typealias Identifier = Int

    static let endpointName = "resource_mock"

    let id: Int

    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
    }

    init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(Identifier.self, forKey: .id)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "resource_mock")
    }
}

/// An listable resource with a field of type `Date` used when testing.
internal struct ResourceWithDateMock: ListableResource {
    typealias Identifier = Int

    static let endpointName = "resource_with_date_mock"

    let id: Int
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

        id = try payload.decode(Identifier.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        date = try attributes.decode(Date.self, forKey: .date)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "resource_with_date_mock")
    }
}
