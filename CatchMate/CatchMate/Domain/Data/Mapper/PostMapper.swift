//
//  PostMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

final class PostMapper {
    func domainToDto(_ domain: RequestPost) -> PostRequset? {
        let gameDateDomain = "\(domain.date) \(domain.playTime)"
        if let date = DateHelper.shared.toDate(from: gameDateDomain, format: "M월d일 EEEE HH:mm") {
            let isoString = DateHelper.shared.toString(from: date, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
            LoggerService.shared.debugLog("PostMapper: Domain -> DTO : \(isoString)")
            return PostRequset(title: domain.title, gameDate: isoString, location: domain.location, homeTeam: domain.homeTeam.rawValue, awayTeam: domain.awayTeam.rawValue, currentPerson: 1, maxPerson: domain.currentPerson, preferGender: domain.preferGender?.serverRequest, preferAge: 28, addInfo: domain.addInfo, writeDate: DateHelper.shared.returniSODateToString())
        } else {
            LoggerService.shared.log("PostMapper: Domain -> DTO 변환 실패", level: .error)
            return nil
        }
    }
}
