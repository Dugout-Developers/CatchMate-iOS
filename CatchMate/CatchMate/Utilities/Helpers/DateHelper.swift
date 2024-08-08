//
//  DateHelper.swift
//  CatchMate
//
//  Created by 방유빈 on 7/4/24.
//

import UIKit

final class DateHelper {
    static let shared = DateHelper()
    
    let dateFormatter: DateFormatter
    let isoFormatter = ISO8601DateFormatter()
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
    }
    
    func toString(from date: Date, format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func toDate(from string: String, format: String) -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    func returniSODateToString() -> String {
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) 
        let currentDate = Date()
        let isoString = isoFormatter.string(from: currentDate)
        return isoString
    }
}

