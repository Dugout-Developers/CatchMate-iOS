//
//  Date+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 7/4/24.
//

import UIKit

extension Date {
    func toString(format: String, timeZone: TimeZone? = nil) -> String {
        if let tz = timeZone {
            return DateHelper.shared.toString(from: self, format: format, timeZone: tz)
        }
        return DateHelper.shared.toString(from: self, format: format)
    }
    
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: date)
    }
    
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: self, to: now)
        
        if let minute = components.minute, minute < 1 {
            return "방금"
        }
        
        if let minute = components.minute, minute < 60 {
            return "\(minute)분 전"
        }
        
        if let hour = components.hour, hour < 24 {
            return "\(hour)시간 전"
        }
        
        if let day = components.day {
            return "\(day)일 전"
        }
        
        return "오래 전"
    }
}
