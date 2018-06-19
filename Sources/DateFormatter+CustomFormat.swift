//
//  DateFormatter+CustomFormat.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 10/06/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

// https://useyourloaf.com/blog/swift-codable-with-custom-dates/
extension DateFormatter {
    static let simpleMDMFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
