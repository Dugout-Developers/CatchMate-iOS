//
//  InquiryDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 3/20/25.
//

import Foundation

struct InquiryDTO: Codable {
    let inquiryId: Int
    let inquiryType: String
    let content: String
    let nickName: String
    let answer: String
    let isCompleted: Bool
    let createdAt: String
}
