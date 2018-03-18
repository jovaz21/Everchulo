//
//  Date+Additions.swift
//  Everchulo
//
//  Created by ATEmobile on 18/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import Foundation

// Date + Strings
extension Date {
    
    // From String
    static func fromString(_ dateString: String, withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return(dateFormatter.date(from: dateString))
    }
    static func fromString(_ dateString: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return(dateFormatter.date(from: dateString))
    }
    
    // To String
    func toString() -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return(dateFormatter.string(from: self))
    }
}
