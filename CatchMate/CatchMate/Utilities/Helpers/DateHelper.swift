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
    let isoFormatter: ISO8601DateFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
    func toString(from date: Date, format: String, timeZone: TimeZone? = TimeZone(identifier: "Asia/Seoul")) -> String {
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func toDate(from string: String, format: String) -> Date? {
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    // ISO8601 형식의 문자열을 받아 date와 playTime으로 변환하는 메서드 추가
    func convertISODateToCustomStrings(isoDateString: String, dateFormat: String = "MM.dd") -> (date: String, playTime: String)? {
        // ISO8601 문자열을 UTC 기준으로 Date 객체로 변환
        let isoDateString = (isoDateString.last != "Z") ? isoDateString + "Z" : isoDateString
        if let date = isoFormatter.date(from: isoDateString) {
            let dateString = toString(from: date, format: dateFormat, timeZone: TimeZone(secondsFromGMT: 0))
            let playTimeString = toString(from: date, format: "HH:mm", timeZone: TimeZone(secondsFromGMT: 0))
            return (dateString, playTimeString)
        }
        
        // 변환 실패 시 nil 반환
        return nil
    }
    
    func convertISOStringToDate(_ isoString: String) -> Date? {
        var correctedString = isoString

        correctedString = correctedString.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
        
        if correctedString.last != "Z" {
            correctedString += "Z"
        }
        
        guard let date = isoFormatter.date(from: correctedString) else {
            return nil
        }
        
        return date
    }
}

