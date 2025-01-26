//
//  ChatListInfo.swift
//  CatchMate
//
//  Created by 방유빈 on 1/26/25.
//

import Foundation

struct ChatListInfo {
    let chatRoomId: Int
    let boardTitle: String
    let participantCount: Int
    let cheerTeam: Team
    let lastMessage: String
    let lastMessageAt: Date
    let newChat: Bool
    let notReadCount: Int
   
    var lastTimeAgo: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastMessageAt)
        
        let oneMinute: TimeInterval = 60
        let oneHour: TimeInterval = 3600
        let oneDay: TimeInterval = 86400
        
        // 1분 이하
        if timeInterval < oneMinute {
            return "방금"
        }
        
        // 1시간 이하
        if timeInterval < oneHour {
            let minutes = Int(timeInterval / oneMinute)
            return "\(minutes)분 전"
        }
        
        // 하루 이하
        if timeInterval < oneDay {
            let hours = Int(timeInterval / oneHour)
            return "\(hours)시간 전"
        }
        
        // 하루 이상
        let days = Int(timeInterval / oneDay)
        return "\(days)일 전"
    }
}
