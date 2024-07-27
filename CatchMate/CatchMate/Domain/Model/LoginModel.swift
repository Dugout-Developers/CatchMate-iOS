//
//  LoginModel.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import Foundation

/// 최종 presentation단 전달 모델 
struct LoginModel {
    let id: String
    let email: String
    let accessToken: String
    let refreshToken: String
    let isFirstLogin: Bool
    let nickName: String?
    let gender: Gender?
    let birth: String?
    let profileImage: String?
}
