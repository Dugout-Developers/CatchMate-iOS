//
//  FavoritePostDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import Foundation

struct PostListDTO: Codable {
    let boardId: Int
    let title: String
    let gameDate: String
    let location: String
    let homeTeam: String
    let awayTeam: String
    let currentPerson: Int
    let maxPerson: Int
}
