//
//  User.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import UIKit

struct User {
    var id: String = UUID().uuidString
    var nickName: String
    var age: UInt
    var team: Team
}

enum Gender: String {
    case woman = "여성"
    case man = "남성"
}
