//
//  SignUp.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import Foundation

/// 요청 모델
struct SignUpRequest {
    let email: String
    let provider: String
    let providerId: String
    let gender: String
    let picture: String?
    let fcmToken: String
    let nickName: String
    let birthDate: String
    let favGudan: String
    let watchStyle: String?
}


/// 응답 모델
struct SignUpResponseDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let userId: Int
    let createdAt: String
}

