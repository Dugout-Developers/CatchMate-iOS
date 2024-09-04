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
    let picture: String
    let favGudan: String
    let watchStyle: String
    let gender: String
}

struct BoardInfo: Codable {
    let boardId: Int
    let title: String
    let gameDate: String
    let location: String
    let homeTeam: String
    let awayTeam: String
    let currentPerson: Int
    let maxPerson: Int
    let addInfo: String
}

// Content Struct
struct Content: Codable {
    let enrollId: Int
    let acceptStatus: String
    let description: String
    let userInfo: UserInfo
    let boardInfo: BoardInfo
}

struct ApplyListResponse: Codable {
    let content: [Content]
}
