//
//  LoginModel.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import Foundation

/// 최종 presentation단 전달 모델 
struct LoginModel: Equatable {
    let email: String
    let provider: LoginType
    let providerId: String
    let accessToken: String?
    let refreshToken: String?
    let isFirstLogin: Bool
    let fcmToken: String
    let imageString: String?
    let nickName: String?
    let birth: String?
    let gender: Gender?
    
    static func == (lhs: LoginModel, rhs: LoginModel) -> Bool {
        return lhs.provider == rhs.provider && lhs.providerId == rhs.providerId
    }
}
