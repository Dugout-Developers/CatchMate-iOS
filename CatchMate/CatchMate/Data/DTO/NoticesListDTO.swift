//
//  NoticesListDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 2/26/25.
//

struct NoticesListDTO: Codable {
    let noticeInfoList: [Notices]
    let isLast: Bool
}

struct Notices: Codable {
    let noticeId: Int
    let title: String
    let content: String
    let createdAt: String
    let updatedAt: String
}

