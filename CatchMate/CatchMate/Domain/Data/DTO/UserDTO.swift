//
//  UserDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import UIKit

struct UserDTO: Codable {
    let userID: Int
    let email, picture, pushAgreement, nickName: String
    let favoriteGudan: String
    let description, watchStyle: String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case email, picture, pushAgreement, nickName, favoriteGudan, description, watchStyle
    }
}
