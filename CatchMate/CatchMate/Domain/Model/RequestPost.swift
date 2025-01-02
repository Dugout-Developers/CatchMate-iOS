//
//  RequstPost.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import UIKit

struct RequestPost {
    let title: String
    let homeTeam: Team
    let awayTeam: Team
    let cheerTeam: Team
    let date: Date
    let playTime: String
    let location: String
    let maxPerson: Int
    let preferGender: Gender?
    let preferAge: [Int]
    let addInfo: String
}

struct RequestEditPost {
    let id: String
    let title: String
    let homeTeam: Team
    let awayTeam: Team
    let cheerTeam: Team
    let date: Date
    let playTime: String
    let location: String
    let currentPerson: Int
    let maxPerson: Int
    let preferGender: Gender?
    let preferAge: [Int]
    let addInfo: String
}
