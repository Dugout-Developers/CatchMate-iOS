//
//  PostMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

final class PostMapper {
    func domainToDto(_ domain: RequestPost) -> AddPostRequsetDTO? {
        let dateString = DateHelper.shared.toString(from: domain.date, format: "yyyy-MM-dd")
        let playTime = domain.playTime+":00"
        let resultString = "\(dateString) \(playTime)"
        LoggerService.shared.debugLog("PostMapper: Domain -> DTO : \(resultString)")
        return AddPostRequsetDTO(title: domain.title, gameRequest: GameInfo(homeClubId: domain.homeTeam.serverId, awayClubId: domain.awayTeam.serverId, gameStartDate: resultString, location: domain.location), cheerClubId: domain.cheerTeam.serverId, maxPerson: domain.maxPerson, preferredGender: domain.preferGender?.serverRequest, preferredAgeRange: domain.preferAge.map{String($0)}, content: domain.addInfo, isCompleted: true)
    }
    func domainToDto(_ domain: RequestEditPost) -> EditPostRequsetDTO? {
        let dateString = DateHelper.shared.toString(from: domain.date, format: "yyyy-MM-dd")
        let playTime = domain.playTime+":00"
        let resultString = "\(dateString) \(playTime)"
        LoggerService.shared.debugLog("PostMapper: Domain -> DTO : \(resultString)")
        return EditPostRequsetDTO(boardId: Int(domain.id)!, title: domain.title, gameDate: resultString, location: domain.location, homeTeam: domain.homeTeam.rawValue, awayTeam: domain.awayTeam.rawValue, cheerTeam: domain.cheerTeam.rawValue, currentPerson: domain.currentPerson, maxPerson: domain.maxPerson, preferGender: domain.preferGender?.serverRequest, preferAge: domain.preferAge.map{String($0)}, addInfo: domain.addInfo)
    }
    
    func dtoToDomain(_ dto: PostDTO) -> Post? {
        if let team = Team(rawValue: dto.writer.favGudan), let gender = Gender(serverValue: dto.writer.gender),
           let homeTeam = Team(rawValue: dto.homeTeam), let awayTeam = Team(rawValue: dto.awayTeam), let cheerTeam = Team(rawValue: dto.cheerTeam) {
            if let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: dto.gameDate) {
                let date = convertedDates.date   // "08.13" 형식
                let playTime = convertedDates.playTime   // "09:21" 형식
                LoggerService.shared.debugLog("PostMapper: DTO -> domain 변환 성공")
                var preferAges: [Int] = []
                dto.preferAge.forEach { str in
                    if let age = Int(str) {
                        preferAges.append(age)
                    }
                }
                return Post(id: String(dto.boardId), title: dto.title, writer: SimpleUser(userId: String(dto.writer.userId), nickName: dto.writer.nickName, picture: dto.writer.picture, favGudan: team, gender: gender, birthDate: dto.writer.birthDate, cheerStyle: CheerStyles(rawValue: dto.writer.watchStyle ?? "")), homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: date, playTime: playTime, location: dto.location, maxPerson: dto.maxPerson, currentPerson: 1, preferGender: Gender(serverValue: dto.preferGender ?? ""), preferAge: preferAges, addInfo: dto.addInfo)
            }
        }
        LoggerService.shared.log("PostMapper: DTO -> domain 변환 실패", level: .error)
        return nil
    }

    func postListDTOtoDomain(_ dto: PostListDTO) -> SimplePost? {
        if let homeTeam = Team.init(rawValue: dto.homeTeam), let awayTeam = Team.init(rawValue: dto.awayTeam), let cheerTeam = Team.init(rawValue: dto.cheerTeam ) {
            if let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: dto.gameDate) {
                print(convertedDates)
                let date = convertedDates.date   // "08.13" 형식
                let playTime = convertedDates.playTime   // "09:21" 형식
                
                return SimplePost(id: String(dto.boardId), title: dto.title, homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: date, playTime: playTime, location: dto.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson)
            } else {
                print("날짜 변환 실패")
                LoggerService.shared.log("PostListDTO -> PostList 변환 실패 : 날짜 변환 실패", level: .error)
                return nil
            }
        } else {
            print("팀정보 매칭 실패")
            LoggerService.shared.log("favoriteListDTO -> PostList 변환 실패 : 팀정보 매칭 실패", level: .error)
            return nil
        }
    }
    func favoritePostListDTOtoDomain(_ dto: PostListDTO) -> SimplePost? {
        if let homeTeam = Team.init(rawValue: dto.homeTeam), let awayTeam = Team.init(rawValue: dto.awayTeam), let cheerTeam = Team.init(rawValue: dto.cheerTeam) {
            if let convertedDates = DateHelper.shared.convertISODateToCustomStrings(isoDateString: dto.gameDate) {
                let date = convertedDates.date   // "08.13" 형식
                let playTime = convertedDates.playTime   // "09:21" 형식
                
                return SimplePost(id: String(dto.boardId), title: dto.title, homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: date, playTime: playTime, location: dto.location, maxPerson: dto.maxPerson, currentPerson: dto.currentPerson)
            } else {
                print("날짜 변환 실패")
                LoggerService.shared.log("PostListDTO -> PostList 변환 실패 : 날짜 변환 실패", level: .error)
                return nil
            }
        } else {
            print("팀정보 매칭 실패")
            LoggerService.shared.log("favoriteListDTO -> PostList 변환 실패 : 팀정보 매칭 실패", level: .error)
            return nil
        }
    }
}
