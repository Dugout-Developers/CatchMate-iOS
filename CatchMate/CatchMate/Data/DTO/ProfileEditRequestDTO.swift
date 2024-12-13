//
//  ProfileEditRequestDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 12/12/24.
//

struct ProfileEditRequestDTO: Codable {
    let nickname: String
    let description: String
    let favGudan: String
    let watchStyle: String
}
