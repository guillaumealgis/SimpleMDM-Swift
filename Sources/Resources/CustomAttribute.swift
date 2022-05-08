//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

// sourcery: identifierType = String
/// Custom attributes defined in your account.
///
/// See `CustomAttributeValue` for the values of these attributes associated to devices.
public struct CustomAttribute: FetchableListableResource {
    // sourcery:inline:auto:CustomAttribute.Identifiable
    /// The type of the unique identifier of this resource.
    public typealias ID = String

    /// The unique identifier of this resource.
    public let id: ID
    // sourcery:end

    /// The name of the attribute.
    public let name: String
}
