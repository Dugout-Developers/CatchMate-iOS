//
//  UserDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import UIKit

struct UserDTO: Codable {
    let userID: Int
    let email, picture, gender: String
    let nickName, favoriteGudan, birthDate: String
    let description, watchStyle: String?
    let allAlarm, chatAlarm, enrollAlarm, eventAlarm: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case email, picture, gender, nickName, favoriteGudan, description, birthDate, watchStyle, allAlarm, chatAlarm, enrollAlarm, eventAlarm
    }
}
