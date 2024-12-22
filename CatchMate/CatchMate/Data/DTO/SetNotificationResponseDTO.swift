//
//  SetNotificationResponseDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 12/20/24.
//

struct SetNotificationResponseDTO: Codable {
    let userId: Int
    let alarmType: String
    let isEnabled: String
    let createdAt: String
}
