//
//  BlockUserInfoDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//
struct BlockUserInfoDTO: Codable {
    let userInfoList: [UserDTO]
    let isLast: Bool
}
