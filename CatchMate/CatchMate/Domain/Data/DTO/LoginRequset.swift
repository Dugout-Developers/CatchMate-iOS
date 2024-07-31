//
//  LoginRequset.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import UIKit

/// 요청 모델
struct LoginRequset {
    let provideId: String
    let provider: String
    let email: String
    let picture: String
    let fcmToken: String
}

/// 응답 모델
struct LoginResponse: Codable {
    let accessToken, refreshToken: String
    let isFirstLogin: Bool
}

