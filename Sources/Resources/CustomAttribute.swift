//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

// sourcery: identifierType = String
public struct CustomAttribute: ListableResource {
    // sourcery:inline:auto:CustomAttribute.Identifiable
    public let id: String
    // sourcery:end

    let name: String
}
