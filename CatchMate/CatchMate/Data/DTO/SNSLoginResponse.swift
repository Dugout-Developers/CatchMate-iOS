//
//  KakaoLoginResponse.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit

enum LoginType: String {
    case kakao
    case naver
    case apple
}

struct SNSLoginResponse {
    let id: String
    let email: String
    let loginType: LoginType
}
