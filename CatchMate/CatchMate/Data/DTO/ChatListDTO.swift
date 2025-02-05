//
//  ChatListDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 1/26/25.
//

struct ChatListDTO: Codable {
    let chatRoomInfoList: [ChatRoomInfoDTO]
    let isLast: Bool
}

struct ChatRoomInfoDTO: Codable {
    let chatRoomId: Int
    let boardInfo: ChatPostInfo
    let participantCount: Int
    let lastMessageAt: String
}

struct ChatPostInfo: Codable {
    let boardId: Int
    let title: String
    let cheerClubId: Int
    let currentPerson: Int
    let maxPerson: Int
    let gameInfo: GameInfoDTO
    let userInfo: ChatManangerInfo
}

struct ChatManangerInfo: Codable {
    let userId: Int
}
