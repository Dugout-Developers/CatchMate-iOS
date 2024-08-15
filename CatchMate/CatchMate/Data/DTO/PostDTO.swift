//
//  PostDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 8/15/24.
//

import Foundation

struct WriterDTO: Codable {
    let userId: Int
    let nickName: String
    let picture: String
    let favGudan: String
    let gender: String
    let birthDate: String
}

struct PostDTO: Codable {
    let boardId: Int
    let writer: WriterDTO
    let title: String
    let gameDate: String
    let location: String
    let homeTeam: String
    let awayTeam: String
    let maxPerson: Int
    let preferGender: String
    let preferAge: Int
    let addInfo: String
}
