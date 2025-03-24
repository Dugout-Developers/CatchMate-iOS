//
//  FavoritePostDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import Foundation

struct PostListDTO: Codable {
    let boardInfoList: [PostListInfoDTO]
    let totalPages: Int
    let totalElements: Int
    let isFirst: Bool
    let isLast: Bool
}
struct PostListInfoDTO: Codable {
    let boardId: Int
    let title: String
    let gameInfo: GameInfoDTO
    let cheerClubId: Int
    let currentPerson: Int
    let maxPerson: Int
}
