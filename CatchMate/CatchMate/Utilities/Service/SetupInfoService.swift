//
//  SetupInfoService.swift
//  CatchMate
//
//  Created by 방유빈 on 8/28/24.
//

import UIKit


final class SetupInfoService {
    static let shared = SetupInfoService()
    
    // MARK: - favorite Id 관련
    /// Favorite List 로컬 저장
    func saveFavoriteListIds(_ list: [String]) {
        LoggerService.shared.debugLog("FavoriteListId 로컬 저장")
        LoggerService.shared.debugLog("\(list)")
        UserDefaults.standard.set(list, forKey: UserDefaultsKeys.SetupInfo.favoriteList)
    }
    
    /// FavoriteList Load
    func loadSimplePostIds() -> [String] {
        return UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.SetupInfo.favoriteList) ?? []
    }
    
    /// 배열에 존재하는지 확인
    func isContainsId(_ id: String) -> Bool {
        guard let list = UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.SetupInfo.favoriteList) else {
            return false
        }
        return list.contains(id)
    }
    
    /// add Favorite Element
    func addSimplePostId(_ id: String) {
        var ids = loadSimplePostIds()
        if !ids.contains(id) {
            ids.append(id)
            saveFavoriteListIds(ids)
        }
    }
    
    /// remove Favorite Element
    func removeSimplePostId(_ id: String) {
        var ids = loadSimplePostIds()
        if let index = ids.firstIndex(of: id) {
            ids.remove(at: index)
            saveFavoriteListIds(ids)
        }
    }
    
    
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

