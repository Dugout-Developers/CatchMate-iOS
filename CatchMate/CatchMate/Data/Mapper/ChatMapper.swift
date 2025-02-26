//
//  ChatMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 1/26/25.
//

import UIKit

final class ChatMapper {
    func dtoToDomain(_ dto: ChatRoomInfoDTO) -> ChatListInfo? {
        var lastMessageAt: Date?
        if let dtoLastMessageAt = dto.lastMessageAt {
            let date = DateHelper.shared.convertISOStringToDate(dtoLastMessageAt)
            if date == nil {
                LoggerService.shared.log("ChatListMapper: \(dtoLastMessageAt) - 마지막 메시지 시간 Date 변환 실패")
            }
            lastMessageAt = date
        } else {
            lastMessageAt = nil
        }
        
        guard let postInfo = postInfoToDomain(dto.boardInfo) else {
            return nil
        }
        
        let managerInfo = ManagerInfo(id: dto.boardInfo.userInfo.userId, nickName: dto.boardInfo.userInfo.nickName)
        // TODO: - newChat API 추가 요청하기
        return ChatListInfo(chatRoomId: dto.chatRoomId, postInfo: postInfo, managerInfo: managerInfo, lastMessage: dto.lastMessageContent ?? "", lastMessageAt: lastMessageAt, currentPerson: dto.participantCount, newChat: Bool.random(), notReadCount: dto.unreadMessageCount, chatImage: dto.chatRoomImage)
    }
    
    func postInfoToDomain(_ dto: ChatPostInfo) -> SimplePost? {
        guard let homeTeam = Team(serverId: dto.gameInfo.homeClubId),
              let awayTeam = Team(serverId: dto.gameInfo.awayClubId),
              let cheerTeam = Team(serverId: dto.cheerClubId) else {
            LoggerService.shared.log("ChatListMapper: 팀 정보 변환 실패")
            return nil
        }
        guard let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: dto.gameInfo.gameStartDate ?? "", dateFormat: "M월 d일 EEEE") else {
            LoggerService.shared.log("ChatListMapper 날짜 변환 실패")
            return nil
        }
        let date = convertedDates.date
        let playTime = convertedDates.playTime
        
        return SimplePost(id: String(dto.boardId), title: dto.title, homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: date, playTime: playTime, location: dto.gameInfo.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson)
    }
}
