//
//  NotificationInfo.swift
//  CatchMate
//
//  Created by 방유빈 on 12/19/24.
//

enum NotificationType: String, CaseIterable {
    case all = "ALL"
    case apply = "ENROLL"
    case chat = "CHAT"
    case event = "EVENT"
    
    var settingViewName: String {
        switch self {
        case .all:
            "전체 알림"
        case .apply:
            "직관 신청 알림"
        case .chat:
            "채팅 알림"
        case .event:
            "이벤트 알림"
        }
    }
}
struct NotificationInfo {
    let all: Bool
    let apply: Bool
    let chat: Bool
    let event: Bool
    
    init(all: Bool, apply: Bool, chat: Bool, event: Bool) {
        self.all = all
        self.apply = apply
        self.chat = chat
        self.event = event
    }
    
    init(user: User) {
        self.all = user.allAlarm
        self.apply = user.enrollAlarm
        self.chat = user.chatAlarm
        self.event = user.eventAlarm
    }
}
