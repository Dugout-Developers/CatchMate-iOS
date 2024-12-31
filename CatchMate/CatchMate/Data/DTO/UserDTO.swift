//
//  UserDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import UIKit

struct UserDTO: Codable {
    let userId: Int
    let email, profileImageUrl, gender, nickName, birthDate: String
    let favoriteClub: FavoriteClub
    let watchStyle: String?
    let allAlarm, chatAlarm, enrollAlarm, eventAlarm: String
}

struct FavoriteClub: Codable {
    let id: Int
    let name: String
    let homeStadium: String
    let region: String
}
