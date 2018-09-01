//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

public struct DeviceGroup: ListableResource {
    // sourcery:inline:auto:DeviceGroup.Identifiable
    public let id: Int
    // sourcery:end

    let name: String
}
