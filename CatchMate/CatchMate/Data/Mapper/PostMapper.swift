//
//  PostMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//
import UIKit

final class PostMapper {
    func domainToDto(_ domain: RequestPost) -> PostRequsetDTO? {
        let dateString = DateHelper.shared.toString(from: domain.date, format: "yyyy-MM-dd")
        let playTime = domain.playTime+":00"
        let resultString = "\(dateString) \(playTime)"
        LoggerService.shared.log("PostMapper: Domain -> DTO : \(resultString)")
        
        let genderStr = domain.preferGender == nil ? "" : domain.preferGender!.serverRequest
        return PostRequsetDTO(title: domain.title, gameRequest: GameInfo(homeClubId: domain.homeTeam.serverId, awayClubId: domain.awayTeam.serverId, gameStartDate: resultString, location: domain.location), cheerClubId: domain.cheerTeam.serverId, maxPerson: domain.maxPerson, preferredGender: genderStr, preferredAgeRange: domain.preferAge.map{String($0)}, content: domain.addInfo, isCompleted: true)
    }
    func domainToDto(_ domain: RequestEditPost) -> PostRequsetDTO? {
        let dateString = DateHelper.shared.toString(from: domain.date, format: "yyyy-MM-dd")
        let playTime = domain.playTime+":00"
        let resultString = "\(dateString) \(playTime)"
        LoggerService.shared.log("PostMapper: Domain -> DTO : \(resultString)")
        let preferAge = domain.preferAge.compactMap{String($0)}
        let genderStr = domain.preferGender == nil ? "" : domain.preferGender!.serverRequest
        return PostRequsetDTO(title: domain.title, gameRequest: GameInfo(homeClubId: domain.homeTeam.serverId, awayClubId: domain.awayTeam.serverId, gameStartDate: resultString, location: domain.location), cheerClubId: domain.cheerTeam.serverId, maxPerson: domain.maxPerson, preferredGender: genderStr, preferredAgeRange: preferAge, content: domain.addInfo, isCompleted: true)
    }
    
    func domainToDto(_ domain: TempPostRequest) -> PostRequsetDTO? {
        var dateResult: String?
        if let date = domain.date, let playTime = domain.playTime {
            let dateString = DateHelper.shared.toString(from: date, format: "yyyy-MM-dd")
            let playTimeString = playTime+":00"
            dateResult = "\(dateString) \(playTimeString)"
        }
        return PostRequsetDTO(title: domain.title ?? "", gameRequest: GameInfo(homeClubId: domain.homeTeam?.serverId ?? 0, awayClubId: domain.awayTeam?.serverId ?? 0, gameStartDate: dateResult, location: domain.location ?? ""), cheerClubId: domain.cheerTeam?.serverId ?? 0, maxPerson: domain.maxPerson ?? 0, preferredGender: domain.preferGender?.serverRequest ?? "", preferredAgeRange: domain.preferAge.map{String($0)}, content: domain.addInfo ?? "", isCompleted: false)
    }
    
    func dtoToDomainTemp(_ dto: PostDTO) -> TempPost {
        let gameInfo = dto.gameInfo
        let convertDate = DateHelper.shared.convertISODateToCustomStrings(isoDateString: gameInfo.gameStartDate ?? "")
        var date: Date?
        var playTime: PlayTime?
        if let dateStr = convertDate?.date {
            date = DateHelper.shared.toDate(from: dateStr, format: "MM.dd")
        }
        if let playTimeStr = convertDate?.playTime {
            playTime = PlayTime(rawValue: playTimeStr)
        }
        let location = gameInfo.location
        let maxPerson = dto.maxPerson == 0 ? nil : dto.maxPerson
        let preferAge = dto.preferredAgeRange.split(separator: ",").compactMap{Int($0)}
        return TempPost(id: String(dto.boardId), title: dto.title, homeTeam: Team(serverId: gameInfo.homeClubId), awayTeam: Team(serverId: gameInfo.awayClubId), cheerTeam: Team(serverId: dto.cheerClubId), date: date, playTime: playTime, location: location, maxPerson: maxPerson, preferGender: Gender(serverValue: dto.preferredGender), preferAge: preferAge, addInfo: dto.content)
    }
    
    func dtoToDomain(_ dto: PostDTO) -> Post? {
        let writer = dto.userInfo
        let gameInfo = dto.gameInfo
        guard let writerTeam = Team(serverId: writer.favoriteClub.id),
        let writerGender = Gender(serverValue: writer.gender) else {
            LoggerService.shared.log("Post DTO -> Post Mapping Error: Writer Info 매칭 실패")
            return nil
        }
        guard let homeTeam = Team(serverId: gameInfo.homeClubId),
              let awayTeam = Team(serverId: gameInfo.awayClubId),
              let cheerTeam = Team(serverId: dto.cheerClubId) else {
            LoggerService.shared.log("Post DTO -> Post Mapping Error: Game Info 매칭 실패")
            return nil
        }
        
        guard let gameDate = DateHelper.shared.convertISODateToCustomStrings(isoDateString: gameInfo.gameStartDate ?? "") else {
            LoggerService.shared.log("Post DTO -> Post Mapping Error: Game Date 변환 실패")
            return nil
        }

        let writerCheerStyle: CheerStyles? = writer.watchStyle != nil ? CheerStyles(rawValue: writer.watchStyle!) : nil
        let preferAges: [Int] = dto.preferredAgeRange.split(separator: ",").compactMap{ Int($0) }
        let gender = dto.preferredGender != "" ? Gender(serverValue: dto.preferredGender) : nil
        return Post(id: String(dto.boardId), title: dto.title, writer: SimpleUser(userId: writer.userId, nickName: writer.nickName, picture: writer.profileImageUrl, favGudan: writerTeam, gender: writerGender, birthDate: writer.birthDate, cheerStyle: writerCheerStyle), homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: gameDate.date, playTime: gameDate.playTime, location: gameInfo.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson, preferGender: gender, preferAge: preferAges, addInfo: dto.content, chatRoomId: dto.chatRoomId)
    }

    func postListDTOtoDomain(_ dto: PostListInfoDTO) -> SimplePost? {
        let gameInfo = dto.gameInfo
        guard let homeTeam = Team.init(serverId: gameInfo.homeClubId),
              let awayTeam = Team.init(serverId: gameInfo.awayClubId),
              let cheerTeam = Team.init(serverId: dto.cheerClubId) else {
            LoggerService.shared.log("favoriteListDTO -> PostList 변환 실패 : 팀정보 매칭 실패")
            return nil
        }
        guard let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: gameInfo.gameStartDate ?? "", dateFormat: "M월 d일 EEEE") else {
            LoggerService.shared.log("PostListDTO -> PostList 변환 실패 : 날짜 변환 실패")
            return nil
        }
        let date = convertedDates.date
        let playTime = convertedDates.playTime
        
        return SimplePost(id: String(dto.boardId), title: dto.title, homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: date, playTime: playTime, location: gameInfo.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson)
    }
}
