//
//  PostDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 8/15/24.
//

import Foundation

struct WriterDTO: Codable {
    let userId: Int
    let email: String
    let nickName: String
    let profileImageUrl: String
    let favoriteClub: WriterTeamInfoDTO
    let watchStyle: String?
    let gender: String
    let birthDate: String
}

struct PostDTO: Codable {
    let boardId: Int
    let title: String
    let content: String
    let cheerClubId: Int
    let currentPerson: Int
    let maxPerson: Int
    let userInfo: WriterDTO
    let preferredGender: String
    let preferredAgeRange: String /// , 구분
    let chatRoomId: Int?
    let gameInfo: GameInfoDTO
    let bookMarked: Bool?
    let buttonStatus: String?
}

struct WriterTeamInfoDTO: Codable {
    let id: Int
}

struct GameInfoDTO: Codable {
    let homeClubId: Int
    let awayClubId: Int
    let gameStartDate: String?
    let location: String
}
