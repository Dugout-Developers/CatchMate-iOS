//
//  UserMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

final class UserMapper {
    func userToDomain(_ dto: UserDTO) -> User {
        let team = Team(rawValue: dto.favoriteGudan) ?? .allTeamLove
        let gender = Gender(serverValue: dto.gender) ?? .man
        return User(id: String(dto.userID), email: dto.email, nickName: dto.nickName, birth: dto.birthDate, team: team, gener: gender, cheerStyle: CheerStyles(rawValue: dto.watchStyle ?? ""), profilePicture: dto.picture, allAlarm: dto.allAlarm == "Y" ? true : false, chatAlarm: dto.chatAlarm == "Y" ? true : false, enrollAlarm: dto.enrollAlarm == "Y" ? true : false, eventAlarm: dto.eventAlarm == "Y" ? true : false, description: dto.description)
    }
    
    func profileEditRequestDomainToDTO(domain: ProfileEdit) -> ProfileEditRequestDTO {
        return ProfileEditRequestDTO(request: ProfileEditRequestDTO.Request(nickName: domain.nickName, favGudan: domain.team.rawValue, watchStyle: domain.style != nil ? domain.style!.rawValue : ""), profileImage: domain.imageDataStr ?? "")
    }
}
