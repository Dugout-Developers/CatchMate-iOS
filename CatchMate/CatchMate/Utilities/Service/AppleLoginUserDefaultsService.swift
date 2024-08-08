//
//  LoginUserDefaultsService.swift
//  CatchMate
//
//  Created by 방유빈 on 6/30/24.
//

import Foundation

/// LOGIN 정보 임시 저장 서비스 파일
final class AppleLoginUserDefaultsService {
    static let shared = AppleLoginUserDefaultsService()
   
    /// 로그인 정보 가져올 시 임시데이터 세팅
    func setTempStorage(type: LoginType, id: String, email: String) {
        UserDefaults.standard.setValue(type.rawValue, forKey: LoginKey.typeKey.rawValue)
        UserDefaults.standard.setValue(id, forKey: LoginKey.id.rawValue)
        UserDefaults.standard.setValue(email, forKey: LoginKey.email.rawValue)
    }
    
    /// 회원가입 후 정상적으로 서버에 User 정보 저장 시 임시 저장 데이터 삭제
    func removeTempData(type: LoginType) {
        UserDefaults.standard.removeObject(forKey: LoginKey.typeKey.rawValue)
        LoginKey.allCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
    
    /// 저장된 로그인 정보 가져오기 (nil = 저장된 정보 없거나 온전하지 않음 -> 새로 로그인)
    func getLoginData() -> LoginData? {
        guard let typeString = UserDefaults.standard.string(forKey: LoginKey.typeKey.rawValue),
              let type = LoginType(rawValue: typeString),
              let id = UserDefaults.standard.string(forKey: LoginKey.id.rawValue),
              let email = UserDefaults.standard.string(forKey: LoginKey.email.rawValue) else {
            return nil
        }

        return LoginData(type: type, id: id, email: email)
    }
}

extension AppleLoginUserDefaultsService {
    struct LoginData {
        let type: LoginType
        let id: String
        let email: String
    }
    
    enum LoginType: String {
        case kakao
        case naver
        case apple
    }
    
    enum LoginKey: String, CaseIterable {
        case typeKey
        case id
        case email
    }
}
