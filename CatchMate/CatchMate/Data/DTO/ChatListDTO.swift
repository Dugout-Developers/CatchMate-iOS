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
    let boardInfo: PostListInfoDTO
    let participantCount: Int
    let lastMessageAt: String
}
