//
//  UserInfoDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 8/28/24.
//

import Foundation

// MARK: - UserInfo 관련
struct UserInfoDTO {
    let id: String
    let email: String
    let team: String
    let nickname: String
    let imageUrl: String
}

enum UserInfoType {
    case id
    case email
    case team
    case nickName
    case imageUrl
    
    var key: String {
        switch self {
        case .id:
            return UserDefaultsKeys.SetupInfo.UserInfo.id
        case .email:
            return UserDefaultsKeys.SetupInfo.UserInfo.email
        case .team:
            return UserDefaultsKeys.SetupInfo.UserInfo.team
        case .nickName:
            return UserDefaultsKeys.SetupInfo.UserInfo.nickName
        case .imageUrl:
            return UserDefaultsKeys.SetupInfo.UserInfo.imageUrl
        }
    }
}
