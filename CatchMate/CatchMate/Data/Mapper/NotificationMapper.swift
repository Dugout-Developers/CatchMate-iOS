//
//  NotificationMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 1/7/25.
//

import UIKit

final class NotificationMapper {
    static func dtoToDomain(_ dto: NotificationDTO) -> NotificationList? {
        let gameInfo = dto.boardInfo.gameInfo
        guard let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: gameInfo.gameStartDate) else {
            LoggerService.shared.debugLog("Notification BoardInfo - 날짜 정보 매칭 실패")
            return nil
        }
        let date = convertedDates.date
        let playTime = convertedDates.playTime
        let gameInfoString = "\(date) | \(playTime) | \(gameInfo.location)"
        return NotificationList(id: String(dto.notificationId), title: dto.body, gameInfo: gameInfoString, read: dto.read, imgUrl: dto.senderProfileImageUrl)
    }
}
