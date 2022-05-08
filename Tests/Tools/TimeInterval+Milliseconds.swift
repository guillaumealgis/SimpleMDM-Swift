//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

extension TimeInterval {
    static func milliseconds(_ milliseconds: Double) -> Self {
        Self(milliseconds: milliseconds)
    }

    init(milliseconds: Double) {
        self.init(milliseconds * 1000)
    }
}
