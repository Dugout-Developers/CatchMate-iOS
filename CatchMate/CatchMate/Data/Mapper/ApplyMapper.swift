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
            return ApplyList(enrollId: String(dto.enrollId), acceptStatus: status, addText: dto.description ?? "", user: user, post: post)
        } else {
            LoggerService.shared.log("ApplyMapper: DTO -> Domain 변환 실패", level: .error)
            return nil
        }
    }
    
    func userInfoMapping(_ dto: UserInfo) -> SimpleUser? {
        if let team = Team(rawValue: dto.favGudan), let gender = Gender(serverValue: dto.gender) {
            return SimpleUser(userId: String(dto.userId), nickName: dto.nickName, picture: dto.picture, favGudan: team, gender: gender, birthDate: dto.birthDate, cheerStyle: CheerStyles(rawValue: dto.watchStyle))
        } else {
            return nil
        }
    }
    
    func postInfoMapping(_ dto: BoardInfo) -> SimplePost? {
        if let homeTeam = Team.init(rawValue: dto.homeTeam), let awayTeam = Team.init(rawValue: dto.awayTeam) {
            if let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: dto.gameDate) {
                print(convertedDates)
                let date = convertedDates.date   // "08.13" 형식
                let playTime = convertedDates.playTime   // "09:21" 형식
                
                return SimplePost(id: String(dto.boardId), title: dto.title, homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: homeTeam, date: date, playTime: playTime, location: dto.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson)
            } else {
                print("날짜 변환 실패")
                LoggerService.shared.log("BoardInfo -> PostList 변환 실패 : 날짜 변환 실패", level: .error)
                return nil
            }
        } else {
            print("팀정보 매칭 실패")
            LoggerService.shared.log("BoardInfo -> PostList 변환 실패 : 팀정보 매칭 실패", level: .error)
            return nil
        }
    }

}
