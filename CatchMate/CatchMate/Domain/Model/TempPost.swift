//
//  TempPost.swift
//  CatchMate
//
//  Created by 방유빈 on 1/10/25.
//
import UIKit

struct TempPost {
    var id: String
    let title: String
    let homeTeam: Team?
    let awayTeam: Team?
    let cheerTeam: Team?
    let date: Date?
    let playTime: PlayTime?
    let location: String
    let maxPerson: Int?
    let preferGender: Gender?
    let preferAge: [Int]
    let addInfo: String
}
