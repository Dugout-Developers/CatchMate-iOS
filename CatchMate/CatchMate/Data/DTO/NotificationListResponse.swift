//
//  NotificationListResponse.swift
//  CatchMate
//
//  Created by 방유빈 on 10/8/24.
//

import Foundation

struct NotificationDTO: Codable {
    let notificationId: Int
    let boardId: Int
    let title: String
    let body: String
    let createdAt: String
    let read: Bool
    

}

struct NotificationListResponse: Codable {
    let content: [NotificationDTO]
}
