//
//  SetupInfoService.swift
//  CatchMate
//
//  Created by 방유빈 on 8/28/24.
//

import UIKit


final class SetupInfoService {
    static let shared = SetupInfoService()
    // MARK: - UserInfo 관련
    enum UserInfoType {
        case id
        case email
        case team
    }
    /// UserInfo 저장 -> 개별 저장
    func saveUserInfo(_ user: UserInfoDTO) {
        LoggerService.shared.debugLog("UserInfo 로컬 저장")
        LoggerService.shared.debugLog("\(user.id) - \(user.email) - team: \(user.team)")
        UserDefaults.standard.set(user.id, forKey: UserDefaultsKeys.SetupInfo.UserInfo.id)
        UserDefaults.standard.set(user.email, forKey: UserDefaultsKeys.SetupInfo.UserInfo.email)
        UserDefaults.standard.set(user.team, forKey: UserDefaultsKeys.SetupInfo.UserInfo.team)
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

        }
    }
    
    /// remove UserInfo -> 로그아웃 시
    func removeUserInfo() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.SetupInfo.UserInfo.id)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.SetupInfo.UserInfo.email)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.SetupInfo.UserInfo.team)
    }
}

