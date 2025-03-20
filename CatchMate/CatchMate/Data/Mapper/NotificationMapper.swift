//
//  NotificationMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 1/7/25.
//

import UIKit

final class NotificationMapper {
    struct MapppingGameResult {
        let boardId: Int
        let gameInfoString: String
    }
    
    func dtoToDomain(_ dto: NotificationDTO) -> NotificationList? {
        if let boardInfo = dto.boardInfo, let mappingResult = mappingGameInfo(boardInfo: boardInfo) {
            return NotificationList(id: String(dto.notificationId), title: dto.body, gameInfo: mappingResult.gameInfoString, read: dto.read, imgUrl: dto.senderProfileImageUrl ?? "", type: NotificationNavigationType(serverValue: dto.acceptStatus ?? ""), boardId: mappingResult.boardId, inquiryId: nil)
        }
        
        if let inquiryInfo = dto.inquiryInfo {
            return NotificationList(id: String(dto.notificationId), title: dto.body, gameInfo: dateFormmat(dtoString: dto.createdAt), read: dto.read, imgUrl: "catchmate", type: NotificationNavigationType(serverValue: "INQUIRY"), boardId: nil, inquiryId: inquiryInfo.inquiryId)
        }
        
        LoggerService.shared.log("Notification BoardInfo - 데이터 매칭 실패")
        return nil
    }
    private func dateFormmat(dtoString: String) -> String {
        let date = DateHelper.shared.convertISOStringToDate(dtoString) ?? Date()
        return DateHelper.shared.toString(from: date, format: "yyyy.MM.dd")
    }
    private func mappingGameInfo(boardInfo: PostDTO) -> MapppingGameResult? {
        let gameInfo = boardInfo.gameInfo
        guard let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: gameInfo.gameStartDate ?? "") else {
            LoggerService.shared.log("Notification BoardInfo - 날짜 정보 매칭 실패")
            return nil
        }
        let date = convertedDates.date
        let playTime = convertedDates.playTime
        let gameInfoString = "\(date) | \(playTime) | \(gameInfo.location)"
        
        return MapppingGameResult(boardId: boardInfo.boardId, gameInfoString: gameInfoString)
    }
}
