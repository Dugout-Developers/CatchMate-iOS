//
//  PostRequset.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//
import Foundation

struct AddPostRequsetDTO: Codable {
    let title: String
    let gameRequest: GameInfo
    let cheerClubId: Int
    let maxPerson: Int
    let preferredGender: String?
    let preferredAgeRange: [String]
    let content: String
    let isCompleted: Bool
}

struct EditPostRequsetDTO: Codable {
    let boardId: Int
    let title: String
    let gameDate: String
    let location: String
    let homeTeam: String
    let awayTeam: String
    let cheerTeam: String
    let currentPerson: Int
    let maxPerson: Int
    let preferGender: String?
    let preferAge: [String]
    let addInfo: String
}

struct GameInfo: Codable {
    let homeClubId: Int
    let awayClubId: Int
    let gameStartDate: String
    let location: String
}
