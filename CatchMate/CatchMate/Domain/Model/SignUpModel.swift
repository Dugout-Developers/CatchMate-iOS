//
//  SignUpModel.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit

struct SignUpModel {
    let nickName: String
    let birth: String
    let team: Team
    let gender: Gender
    let cheerStyle: CheerStyles?
}

struct SignUpResponse {
    let userId: String
    let createdAt: String
    let accessToken: String
    let refreshToken: String
}
