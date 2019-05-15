//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

// sourcery: identifierType = String
/// Custom attributes defined in your account.
///
/// See `CustomAttributeValue` for the values of these attributes associated to devices.
public struct CustomAttribute: ListableResource {
    // sourcery:inline:auto:CustomAttribute.Identifiable
    /// The unique identifier of this resource.
    public let id: String
    // sourcery:end

    /// The name of the attribute.
    public let name: String
}
