//
//  PostList.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//
import Foundation

struct PostList: Identifiable, Equatable {
    var id: String
    let title: String
    let homeTeam: Team
    let awayTeam: Team
//    let cheerTeam: Team -> 넣을지 말지 상의
    let date: String
    let playTime: String
    let location: String
    let maxPerson: Int
    let currentPerson: Int
    var isFinished: Bool {
        if currentPerson == maxPerson {
            return true
        } else {
            return false
        }
    }
    
    static func == (lhs: PostList, rhs: PostList) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(id: String = UUID().uuidString, title: String, homeTeam: Team, awayTeam: Team, date: String, playTime: String, location: String, maxPerson: Int, currentPerson: Int) {
        self.id = id
        self.title = title
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.date = date
        self.playTime = playTime
        self.location = location
        self.maxPerson = maxPerson
        self.currentPerson = currentPerson
    }
}
