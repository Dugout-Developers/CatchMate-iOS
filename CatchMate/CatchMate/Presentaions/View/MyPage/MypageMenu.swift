//
//  MypageMenu.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//

import Foundation

enum MypageMenu: String {
    case notices = "공지사항"
    case customerService = "고객센터"
    case terms = "약관 및 정책"
    case info = "정보"
    
    static var supportMenus: [MypageMenu] {
        return [.notices, .customerService, .terms, .info]
    }
}
