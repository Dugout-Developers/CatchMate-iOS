//
//  PostMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

final class PostMapper {
    func domainToDto(_ domain: RequestPost) -> PostRequsetDTO? {
        let dateString = DateHelper.shared.toString(from: domain.date, format: "yyyy-MM-dd")
        let playTime = domain.playTime+":00"
        let resultString = "\(dateString) \(playTime)"
        LoggerService.shared.debugLog("PostMapper: Domain -> DTO : \(resultString)")
        return PostRequsetDTO(title: domain.title, gameRequest: GameInfo(homeClubId: domain.homeTeam.serverId, awayClubId: domain.awayTeam.serverId, gameStartDate: resultString, location: domain.location), cheerClubId: domain.cheerTeam.serverId, maxPerson: domain.maxPerson, preferredGender: domain.preferGender?.serverRequest, preferredAgeRange: domain.preferAge.map{String($0)}, content: domain.addInfo, isCompleted: true)
    }
    func domainToDto(_ domain: RequestEditPost) -> PostRequsetDTO? {
        let dateString = DateHelper.shared.toString(from: domain.date, format: "yyyy-MM-dd")
        let playTime = domain.playTime+":00"
        let resultString = "\(dateString) \(playTime)"
        LoggerService.shared.debugLog("PostMapper: Domain -> DTO : \(resultString)")
        let preferAge = domain.preferAge.compactMap{String($0)}
        return PostRequsetDTO(title: domain.title, gameRequest: GameInfo(homeClubId: domain.homeTeam.serverId, awayClubId: domain.awayTeam.serverId, gameStartDate: resultString, location: domain.location), cheerClubId: domain.cheerTeam.serverId, maxPerson: domain.maxPerson, preferredGender: domain.preferGender?.rawValue, preferredAgeRange: preferAge, content: domain.addInfo, isCompleted: true)
    }
    
    func domainToDto(_ domain: TempPostRequest) -> PostRequsetDTO? {
        var dateResult = ""
        if let date = domain.date, let playTime = domain.playTime {
            let dateString = DateHelper.shared.toString(from: date, format: "yyyy-MM-dd")
            let playTimeString = playTime+":00"
            dateResult = "\(dateString) \(playTimeString)"
        }
        return PostRequsetDTO(title: domain.title ?? "", gameRequest: GameInfo(homeClubId: domain.homeTeam?.serverId ?? 0, awayClubId: domain.awayTeam?.serverId ?? 0, gameStartDate: dateResult, location: domain.location ?? ""), cheerClubId: domain.cheerTeam?.serverId ?? 0, maxPerson: domain.maxPerson ?? 0, preferredGender: domain.preferGender?.serverRequest ?? "", preferredAgeRange: domain.preferAge.map{String($0)}, content: domain.addInfo ?? "", isCompleted: false)
    }
    
    func dtoToDomain(_ dto: PostDTO) -> Post? {
        let writer = dto.userInfo
        let gameInfo = dto.gameInfo
        guard let writerTeam = Team(serverId: writer.favoriteClub.id),
        let writerGender = Gender(serverValue: writer.gender) else {
            LoggerService.shared.debugLog("Post DTO -> Post Mapping Error: Writer Info 매칭 실패")
            return nil
        }
        guard let homeTeam = Team(serverId: gameInfo.homeClubId),
              let awayTeam = Team(serverId: gameInfo.awayClubId),
              let cheerTeam = Team(serverId: dto.cheerClubId) else {
            LoggerService.shared.debugLog("Post DTO -> Post Mapping Error: Game Info 매칭 실패")
            return nil
        }
        
        guard let gameDate = DateHelper.shared.convertISODateToCustomStrings(isoDateString: gameInfo.gameStartDate) else {
            LoggerService.shared.debugLog("Post DTO -> Post Mapping Error: Game Date 변환 실패")
            return nil
        }

        let writerCheerStyle: CheerStyles? = writer.watchStyle != nil ? CheerStyles(rawValue: writer.watchStyle!) : nil
        let preferAges: [Int] = dto.preferredAgeRange.split(separator: ",").compactMap{ Int($0) }
        return Post(id: String(dto.boardId), title: dto.title, writer: SimpleUser(userId: String(writer.userId), nickName: writer.nickName, picture: writer.profileImageUrl, favGudan: writerTeam, gender: writerGender, birthDate: writer.birthDate, cheerStyle: writerCheerStyle), homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: gameDate.date, playTime: gameDate.playTime, location: gameInfo.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson, preferGender: Gender(serverValue: dto.preferredGender), preferAge: preferAges, addInfo: dto.content)
    }

    func postListDTOtoDomain(_ dto: PostListInfoDTO) -> SimplePost? {
        let gameInfo = dto.gameInfo
        guard let homeTeam = Team.init(serverId: gameInfo.homeClubId),
              let awayTeam = Team.init(serverId: gameInfo.awayClubId),
              let cheerTeam = Team.init(serverId: dto.cheerClubId) else {
            print("팀정보 매칭 실패")
            LoggerService.shared.log("favoriteListDTO -> PostList 변환 실패 : 팀정보 매칭 실패", level: .error)
            return nil
        }
        guard let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: gameInfo.gameStartDate) else {
            print("날짜 변환 실패")
            LoggerService.shared.log("PostListDTO -> PostList 변환 실패 : 날짜 변환 실패", level: .error)
            return nil
        }
        let date = convertedDates.date
        let playTime = convertedDates.playTime
        
        return SimplePost(id: String(dto.boardId), title: dto.title, homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: date, playTime: playTime, location: gameInfo.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson)
    }
}
