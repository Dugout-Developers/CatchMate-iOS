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
    
    init(id: String, email: String, loginType: LoginType, birth: String? = nil, nickName: String? = nil, gender: String? = nil, image: String? = "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.studiopeople.kr%2F&psig=AOvVaw0WompMLL5M4iJ7_pLkKb7i&ust=1722405797923000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCOj8st-LzocDFQAAAAAdAAAAABAP") {
        self.id = id
        self.email = email
        self.loginType = loginType
        self.birth = birth
        self.nickName = nickName
        self.gender = gender
        self.imageUrl = image
    }
}
