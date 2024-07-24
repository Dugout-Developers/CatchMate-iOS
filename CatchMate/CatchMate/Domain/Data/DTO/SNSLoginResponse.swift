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
    let birth: String?
    let nickName: String?
    let gender: String?
    let imageUrl: String?
    
    init(id: String, email: String, loginType: LoginType, birth: String? = nil, nickName: String? = nil, gender: String? = nil, image: String? = nil) {
        self.id = id
        self.email = email
        self.loginType = loginType
        self.birth = birth
        self.nickName = nickName
        self.gender = gender
        self.imageUrl = image
    }
}
