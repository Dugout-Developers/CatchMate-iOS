//
//  User.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import UIKit

struct User {
    var id: String
    let snsID: String
    let email: String
    let nickName: String
    let age: UInt
    let team: Team
    let gener: Gender
    let cheerStyle: CheerStyles?
    let profilePicture: String?
}

enum Gender: String {
    case woman = "여성"
    case man = "남성"
    
    var serverRequest: String {
        switch self {
        case .woman:
            "F"
        case .man:
            "M"
        }
    }
}
