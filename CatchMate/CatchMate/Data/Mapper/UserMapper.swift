//
//  UserMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit

final class UserMapper {
    func userToDomain(_ dto: UserDTO) -> User {
        let team = Team(serverId: dto.favoriteClub.id) ?? .allTeamLove
        let gender = Gender(serverValue: dto.gender) ?? .man
        return User(id: dto.userId, email: dto.email, nickName: dto.nickName, birth: dto.birthDate, team: team, gener: gender, cheerStyle: CheerStyles(rawValue: dto.watchStyle ?? ""), profilePicture: dto.profileImageUrl, allAlarm: dto.allAlarm == "Y" ? true : false, chatAlarm: dto.chatAlarm == "Y" ? true : false, enrollAlarm: dto.enrollAlarm == "Y" ? true : false, eventAlarm: dto.eventAlarm == "Y" ? true : false)
    }
    
    func dtoToDomain(_ dto: UserDTO) -> SimpleUser? {
        guard let team = Team(serverId: dto.favoriteClub.id) else {
            LoggerService.shared.log("팀정보 변환 실패")
            return nil
        }
        guard let gender = Gender(serverValue: dto.gender) else {
            LoggerService.shared.log("성별 정보 변환 실패")
            return nil
        }
        
        return SimpleUser(userId: dto.userId, nickName: dto.nickName, picture: dto.profileImageUrl, favGudan: team, gender: gender, birthDate: dto.birthDate, cheerStyle: CheerStyles(rawValue: dto.watchStyle ?? ""))
    }
    
    func profileEditRequestDomainToDTO(domain: ProfileEdit) -> ProfileEditRequestDTO {
        return ProfileEditRequestDTO(request: ProfileEditRequestDTO.Request(nickName: domain.nickName, favoriteClubId: domain.team.serverId, watchStyle: domain.style != nil ? domain.style!.rawValue : ""), profileImage: domain.image ?? UIImage(named: "defaultImg")!)
    }
}
