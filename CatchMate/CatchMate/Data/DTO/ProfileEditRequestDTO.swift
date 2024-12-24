//
//  ProfileEditRequestDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 12/12/24.
//

struct ProfileEditRequestDTO: Codable {
    let request: Request
    let profileImage: String
    
    struct Request: Codable {
        let nickName: String
        let favGudan: String
        let watchStyle: String
    }
}
