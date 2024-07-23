//
//  SignUp.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import Foundation

/// 요청 모델
struct SignUpRequest {
    let nickName: String
    let birthDate: String
    let favoriteGudan: String
    let watchStyle: String
}

/// 응답 모델
struct SignUpResponseDTO: Codable {
    let userId: Int
    let createdAt: String
}
