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
        return User(id: String(dto.userID), email: dto.email, nickName: dto.nickName, birth: dto.birthDate, team: team, gener: gender, cheerStyle: CheerStyles(rawValue: dto.watchStyle ?? ""), profilePicture: dto.picture, pushAgreement: dto.pushAgreement == "Y" ? true : false, description: dto.description)
    }
}
