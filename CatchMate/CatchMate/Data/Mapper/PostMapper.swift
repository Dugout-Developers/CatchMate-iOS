//
//  PostMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

final class PostMapper {
    func domainToDto(_ domain: RequestPost) -> PostRequsetDTO? {
        let gameDateDomain = "\(domain.date) \(domain.playTime)"
        
        if let date = DateHelper.shared.toDate(from: gameDateDomain, format: "M월d일 EEEE HH:mm"), let preferGender = domain.preferGender?.serverRequest {
            let resultString = DateHelper.shared.toString(from: date, format: "yyyy-MM-dd HH:mm:ss")
            LoggerService.shared.debugLog("PostMapper: Domain -> DTO : \(resultString)")
            return PostRequsetDTO(title: domain.title, gameDate: resultString, location: domain.location, homeTeam: domain.homeTeam.rawValue, awayTeam: domain.awayTeam.rawValue, currentPerson: 1, maxPerson: domain.maxPerson, preferGender: preferGender, preferAge: 28, addInfo: domain.addInfo)
        } else {
            LoggerService.shared.log("PostMapper: Domain -> DTO 변환 실패", level: .error)
            return nil
        }
    }

    func postListDTOtoDomain(_ dto: PostListDTO) -> PostList? {
        if let homeTeam = Team.init(rawValue: dto.homeTeam), let awayTeam = Team.init(rawValue: dto.awayTeam) {
            if let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: dto.gameDate) {
                let date = convertedDates.date   // "08.13" 형식
                let playTime = convertedDates.playTime   // "09:21" 형식
                
                return PostList(id: String(dto.boardId), title: dto.title, homeTeam: homeTeam, awayTeam: awayTeam, date: date, playTime: playTime, location: dto.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson)
            } else {
                LoggerService.shared.log("favoriteListDTO -> PostList 변환 실패 : 날짜 변환 실패", level: .error)
                return nil
            }
        } else {
            LoggerService.shared.log("favoriteListDTO -> PostList 변환 실패 : 팀정보 매칭 실패", level: .error)
            return nil
        }
    }
}
