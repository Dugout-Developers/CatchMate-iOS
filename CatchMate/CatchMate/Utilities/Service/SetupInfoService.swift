//
//  SetupInfoService.swift
//  CatchMate
//
//  Created by 방유빈 on 8/28/24.
//

import UIKit


final class SetupInfoService {
    static let shared = SetupInfoService()
    /// UserInfo 저장 - 한번에
    func saveUserInfo(_ user: UserInfoDTO) {
        LoggerService.shared.log(level: .info, "UserInfo 로컬 전체 저장: \(user.id) - \(user.email) - team: \(user.team) - nickName: \(user.nickname)")
        UserDefaults.standard.set(user.id, forKey: UserDefaultsKeys.SetupInfo.UserInfo.id)
        UserDefaults.standard.set(user.email, forKey: UserDefaultsKeys.SetupInfo.UserInfo.email)
        UserDefaults.standard.set(user.team, forKey: UserDefaultsKeys.SetupInfo.UserInfo.team)
        UserDefaults.standard.set(user.nickname, forKey: UserDefaultsKeys.SetupInfo.UserInfo.nickName)
        UserDefaults.standard.set(user.imageUrl, forKey: UserDefaultsKeys.SetupInfo.UserInfo.imageUrl)
    }
    
    /// UserInfo 저장 - 개별 저장
    func saveUserInfo(type: UserInfoType, _ value: String) {
        UserDefaults.standard.set(value, forKey: type.key)
    }
    
    /// 필요한 정보 get
    func getUserInfo(type: UserInfoType) -> String? {
        switch type {
        case .id:
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.SetupInfo.UserInfo.id)
        case .email:
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.SetupInfo.UserInfo.email)
        case .team:
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.SetupInfo.UserInfo.team)
        case .nickName:
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.SetupInfo.UserInfo.nickName)
        case .imageUrl:
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.SetupInfo.UserInfo.imageUrl)
        }
    }
    
    func getUsertInfo() -> UserInfoDTO? {
        guard let id = getUserInfo(type: .id),
              let email = getUserInfo(type: .email),
              let team = getUserInfo(type: .team),
              let nickName = getUserInfo(type: .nickName),
              let imageUrl = getUserInfo(type: .imageUrl)
        else { return nil }
        return UserInfoDTO(id: id, email: email, team: team, nickname: nickName, imageUrl: imageUrl)
    }
    
    /// remove UserInfo -> 로그아웃 시
    func removeUserInfo() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.SetupInfo.UserInfo.id)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.SetupInfo.UserInfo.email)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.SetupInfo.UserInfo.team)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.SetupInfo.UserInfo.nickName)
    }
}

