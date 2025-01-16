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


extension PostRequsetDTO {
    func encodingData() -> [String: Any] {
        let parameters: [String: Any] = [
            "title": self.title,
            "content": self.content,
            "maxPerson": self.maxPerson,
            "cheerClubId": self.cheerClubId,
            "preferredGender": self.preferredGender ?? "N",
            "preferredAgeRange": self.preferredAgeRange,
            "gameRequest": [
                "homeClubId": self.gameRequest.homeClubId,
                "awayClubId": self.gameRequest.awayClubId,
                "gameStartDate": self.gameRequest.gameStartDate,
                "location": self.gameRequest.location
            ],
            "isCompleted": self.isCompleted
        ]
        
        return parameters
    }
}
