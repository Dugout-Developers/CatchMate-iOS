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
            LoggerService.shared.log("ChatListMapper: \(dto.chatRoomId)번 \(dto.boardInfo.title) - 응원구단 변환 실패")
            return nil
        }

        guard let lastMessageAt = DateHelper.shared.convertISOStringToDate(dto.lastMessageAt) else {
            LoggerService.shared.log("ChatListMapper: \(dto.lastMessageAt) - 마지막 메시지 시간 Date 변환 실패")
            return nil
        }
        
        guard let postInfo = postInfoToDomain(dto.boardInfo) else {
            return nil
        }
        
        // TODO: - newChat, lastMessage, notReadCount API 추가 요청하기
        return ChatListInfo(chatRoomId: dto.chatRoomId, postInfo: postInfo, managerId: dto.boardInfo.userInfo.userId, lastMessage: "새 메시지가 도착했습니다.", lastMessageAt: lastMessageAt, newChat: Bool.random(), notReadCount: Int.random(in: 0...10))
    }
    
    func postInfoToDomain(_ dto: ChatPostInfo) -> SimplePost? {
        guard let homeTeam = Team(serverId: dto.gameInfo.homeClubId),
              let awayTeam = Team(serverId: dto.gameInfo.awayClubId),
              let cheerTeam = Team(serverId: dto.cheerClubId) else {
            LoggerService.shared.log("ChatListMapper: 팀 정보 변환 실패")
            return nil
        }
        guard let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: dto.gameInfo.gameStartDate ?? "") else {
            LoggerService.shared.log("ChatListMapper 날짜 변환 실패")
            return nil
        }
        let date = convertedDates.date
        let playTime = convertedDates.playTime
        
        return SimplePost(id: String(dto.boardId), title: dto.title, homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: date, playTime: playTime, location: dto.gameInfo.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson)
    }
}
