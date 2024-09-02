//
//  PostRequset.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//
import Foundation

struct AddPostRequsetDTO: Codable {
    let title: String
    let gameDate: String
    let location: String
    let homeTeam: String
    let awayTeam: String
    let cheerTeam: String
    let maxPerson: Int
    let preferGender: String
    let preferAge: Int
    let addInfo: String
}
