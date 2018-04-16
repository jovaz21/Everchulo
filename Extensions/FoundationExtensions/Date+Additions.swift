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
    static func fromString(_ dateStr: String, withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return(dateFormatter.date(from: dateStr))
    }
    static func fromString(_ dateString: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return(dateFormatter.date(from: dateString))
    }
    
    // To String
    func toString(withFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return(dateFormatter.string(from: self))
    }
    func toString() -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return(dateFormatter.string(from: self))
    }
}

// Rounding Dates
enum DateRoundingType {
    case round
    case ceil
    case floor
}
extension Date {
    func rounded(minutes: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        return rounded(seconds: minutes * 60, rounding: rounding)
    }
    func rounded(seconds: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        var roundedInterval: TimeInterval = 0
        switch rounding  {
        case .round:
            roundedInterval = (timeIntervalSinceReferenceDate / seconds).rounded() * seconds
        case .ceil:
            roundedInterval = ceil(timeIntervalSinceReferenceDate / seconds) * seconds
        case .floor:
            roundedInterval = floor(timeIntervalSinceReferenceDate / seconds) * seconds
        }
        return Date(timeIntervalSinceReferenceDate: roundedInterval)
    }
}
