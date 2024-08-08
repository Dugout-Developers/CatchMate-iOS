//
//  UserDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import UIKit
struct UserDTO: Codable {
    let userID: Int
    let email, picture, gender, pushAgreement: String
    let nickName, favoriteGudan, birthDate: String
    let description, watchStyle: String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case email, picture, gender, pushAgreement, nickName, favoriteGudan, description, birthDate, watchStyle
    }
}
