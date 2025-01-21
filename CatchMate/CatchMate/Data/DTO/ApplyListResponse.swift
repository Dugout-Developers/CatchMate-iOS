//
//  ApplyListResponse.swift
//  CatchMate
//
//  Created by 방유빈 on 9/3/24.
//

import Foundation
// 받은 신청에서는 신청자 정보, 보낸 신청에서는 작성자 정보
struct UserInfo: Codable {
    let userId: Int
    let nickName: String
    let profileImageUrl: String
    let favoriteClub: FavoriteClub
    let watchStyle: String
    let gender: String
    let birthDate: String
}

// Content Struct
struct Content: Codable {
    let enrollId: Int
    let acceptStatus: String
    let description: String
    let userInfo: UserInfo
    let boardInfo: PostListInfoDTO
    let new: Bool?
}

struct ApplyListResponse: Codable {
    let enrollInfoList: [Content]
    let isLast: Bool
}
