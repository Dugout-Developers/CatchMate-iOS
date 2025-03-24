//
//  Notification.swift
//  CatchMate
//
//  Created by 방유빈 on 1/7/25.
//

struct NotificationList: Equatable {
    let id: String
    let title: String
    let gameInfo: String
    let read: Bool
    let imgUrl: String
    let type: NotificationNavigationType
    let boardId: Int?
    let inquiryId: Int?
    
    static func == (lhs: NotificationList, rhs: NotificationList) -> Bool {
        lhs.id == rhs.id
    }
}

enum NotificationNavigationType {
    case receivedView
    case chatRoom
    case inquiry
    case none
    
    init(serverValue: String) {
        if serverValue == "PENDING" {
            self = .receivedView
        } else if serverValue == "ACCEPTED" {
            self = .chatRoom
        } else if serverValue == "INQUIRY"{
            self = .inquiry
        } else {
            self = .none
        }
    }
}
