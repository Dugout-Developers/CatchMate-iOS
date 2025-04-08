//
//  Post.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

struct Post: Identifiable, Equatable {
    var id: String
    let title: String
    let writer: SimpleUser
    let homeTeam: Team
    let awayTeam: Team
    let cheerTeam: Team 
    let date: String
    let playTime: String
    let location: String
    let maxPerson: Int
    let currentPerson: Int
    let preferGender: Gender?
    let preferAge: [Int]
    let addInfo: String
    let chatRoomId: Int?
    let gameDateString: String
    var isFinished: Bool {
        if currentPerson == maxPerson {
            return true
        } else {
            return false
        }
    }
    var isFinishGame: Bool {
        if let targetDate = DateHelper.shared.toDate(from: gameDateString, format: "yyyy-MM-dd'T'HH:mm:ss") {
            
            if targetDate < Date() {
                return true
            }  else {
                return false
            }
        }
        return false
    }
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }

}

