//
//  PostRequset.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//
import Foundation

struct PostRequsetDTO: Codable {
    let title: String
    let gameRequest: GameInfo
    let cheerClubId: Int
    let maxPerson: Int
    let preferredGender: String?
    let preferredAgeRange: [String]
    let content: String
    let isCompleted: Bool
}

struct GameInfo: Codable {
    let homeClubId: Int
    let awayClubId: Int
    let gameStartDate: String?
    let location: String
}
