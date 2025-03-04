//
//  Announcements.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import Foundation

struct Announcement: Equatable {
    let id: Int
    let title: String
    let writeDate: Date
    let contents: String
    
    var dateString: String {
        return DateHelper.shared.toString(from: writeDate, format: "YYYY년 M월 d일")
    }
    static func == (lhs: Announcement, rhs: Announcement) -> Bool {
        return lhs.id == rhs.id
    }
}
