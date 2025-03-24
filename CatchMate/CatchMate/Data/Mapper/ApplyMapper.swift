//
//  ApplyMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 9/5/24.
//

import Foundation
final class ApplyMapper {
    func dtoToDomain(_ dto: Content) -> ApplyList? {
        if let status = ApplyStatus(rawValue: dto.acceptStatus), let user = userInfoMapping(dto.userInfo), let post = postInfoMapping(dto.boardInfo) {
            return ApplyList(enrollId: String(dto.enrollId), acceptStatus: status, addText: dto.description, user: user, post: post, new: dto.new ?? false)
        } else {
            LoggerService.shared.log("ApplyMapper: DTO -> Domain 변환 실패")
            return nil
        }
    }
    
    func userInfoMapping(_ dto: UserInfo) -> SimpleUser? {
        guard let favoriteClub = Team(serverId: dto.favoriteClub.id) else {
            LoggerService.shared.log("Apply UserInfo - 응원 구단 매칭 실패")
            return nil
        }
        guard let gender = Gender(serverValue: dto.gender) else {
            LoggerService.shared.log("Apply UserInfo - 성별 매칭 실패")
            return nil
        }
        let cheerStyle = dto.watchStyle == nil ? nil : CheerStyles(rawValue: dto.watchStyle!)
        return SimpleUser(userId: dto.userId, nickName: dto.nickName, picture: dto.profileImageUrl, favGudan: favoriteClub, gender: gender, birthDate: dto.birthDate, cheerStyle: cheerStyle)
    }
    
    func postInfoMapping(_ dto: PostListInfoDTO) -> SimplePost? {
        
        let gameInfo = dto.gameInfo
        guard let homeTeam = Team(serverId: gameInfo.homeClubId), let awayTeam = Team(serverId: gameInfo.awayClubId), let cheerTeam = Team(serverId: dto.cheerClubId) else {
            LoggerService.shared.log("Apply BoardInfo - 팀정보 매칭 실패")
            return nil
        }
        guard let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: gameInfo.gameStartDate ?? "") else {
            LoggerService.shared.log("Apply BoardInfo - 날짜 정보 매칭 실패")
            return nil
        }
        let date = convertedDates.date   // "08.13" 형식
        let playTime = convertedDates.playTime   // "09:21" 형식
        
        return SimplePost(id: String(dto.boardId), title: dto.title, homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: date, playTime: playTime, location: dto.gameInfo.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson)
    }
    
    func receivedApplyMapping(_ dto: EnrollInfo) -> RecivedApplies? {
        guard let post = postInfoMapping(dto.boardInfo) else {
            LoggerService.shared.log("Received Apply Mapping - Post 정보 매칭 실패")
            return nil
        }
        
        let applies: [RecivedApplyData] = dto.enrollReceiveInfoList.compactMap { enrollInfo in
            guard let user = userInfoMapping(enrollInfo.userInfo) else {
                LoggerService.shared.log("Received Apply Mapping(\(enrollInfo.enrollId)번 신청 - User 정보 매칭 실패")
                return nil
            }
            guard let date = DateHelper.shared.convertISOStringToDate(enrollInfo.requestDate) else {
                LoggerService.shared.log("Received Apply Mapping(\(enrollInfo.enrollId)번 신청 - Date parsing 실패")
                return nil
            }
            return RecivedApplyData(
                enrollId: String(enrollInfo.enrollId),
                user: user,
                addText: enrollInfo.description,
                requestDate: date,
                new: enrollInfo.isNew
            )
        }
        
        return RecivedApplies(post: post, applies: applies)
    }
}
