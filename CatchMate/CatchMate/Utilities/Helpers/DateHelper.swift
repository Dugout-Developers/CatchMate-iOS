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
    // ISO8601 형식의 문자열을 받아 date와 playTime으로 변환하는 메서드 추가
    func convertISODateToCustomStrings(isoDateString: String) -> (date: String, playTime: String)? {
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // ISO8601 문자열을 Date 객체로 변환
        if let date = isoFormatter.date(from: isoDateString) {
            // Date 객체를 원하는 포맷의 문자열로 변환
            let dateString = toString(from: date, format: "MM.dd")
            let playTimeString = toString(from: date, format: "HH:mm")
            return (dateString, playTimeString)
        }
        
        // 변환 실패 시 nil 반환
        return nil
    }
}

