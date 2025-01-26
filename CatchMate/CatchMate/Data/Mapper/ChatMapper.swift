//
//  ChatMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 1/26/25.
//

import UIKit

final class ChatMapper {
    func dtoToDomain(_ dto: ChatRoomInfoDTO) -> ChatListInfo? {
        guard let cheerTeam = Team(serverId: dto.boardInfo.cheerClubId) else {
            LoggerService.shared.debugLog("ChatListMapper: \(dto.chatRoomId)번 \(dto.boardInfo.title) - 응원구단 변환 실패")
            return nil
        }
        
        guard let lastMessageAt = DateHelper.shared.convertISOStringToDate(dto.lastMessageAt) else {
            LoggerService.shared.debugLog("ChatListMapper: \(dto.lastMessageAt) - 마지막 메시지 시간 Date 변환 실패")
            return nil
        }
        // TODO: - newChat, lastMessage, notReadCount API 추가 요청하기
        return ChatListInfo(chatRoomId: dto.chatRoomId, boardTitle: dto.boardInfo.title, participantCount: dto.participantCount, cheerTeam: cheerTeam, lastMessage: "새 메시지가 도착했습니다.", lastMessageAt: lastMessageAt, newChat: Bool.random(), notReadCount: Int.random(in: 0...10))
    }
}
