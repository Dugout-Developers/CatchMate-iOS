//
//  SignUpModel.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit

struct SignUpModel {
    let accessToken: String
    let refreshToken: String
    let nickName: String
    let birth: String
    let team: Team
    let cheerStyle: CheerStyles?
}

struct SignUpResponse {
    let userId: Int
    let createdAt: String
}
