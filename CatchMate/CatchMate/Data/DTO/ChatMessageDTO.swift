//
//  ChatMessageDTo.swift
//  CatchMate
//
//  Created by 방유빈 on 2/4/25.
//
import Foundation

struct ChatMessageDTO: Codable {
    let chatMessageInfoList: [ChatMessageInfo]
    let isLast: Bool
}

struct ChatMessageInfo: Codable {
    let timeInfo: TimeInfo
    let roomId: Int
    let content: String
    let senderId: Int
    
    enum CodingKeys: String, CodingKey {
        case timeInfo = "id"
        case roomId, content, senderId
    }
}

struct TimeInfo: Codable {
    let date: String
}
