//
//  ReportUserDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

struct ReportUserDTO: Codable {
    let reportedUserId: Int
    let reportType: String
    let content: String
}
