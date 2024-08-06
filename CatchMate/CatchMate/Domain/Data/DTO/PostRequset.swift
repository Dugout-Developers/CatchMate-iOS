//
//  PostRequset.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//
import Foundation

struct PostRequset: Codable {
    let title, gameDate, location, homeTeam: String
    let awayTeam: String
    let currentPerson, maxPerson: Int
    let preferGender: String
    let preferAge: Int
    let addInfo, writeDate: String
}
