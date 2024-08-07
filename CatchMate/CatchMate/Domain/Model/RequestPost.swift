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
    let date: String
    let playTime: String
    let location: String
    let maxPerson: Int
    let preferGender: Gender?
    let preferAge: [Int]
    let addInfo: String?
}
