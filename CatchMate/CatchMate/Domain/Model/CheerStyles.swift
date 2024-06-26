//
//  CheerStyles.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit

enum CheerStyles: String, CaseIterable {
    case director = "감독 스타일"
    case mom = "어미새 스타일"
    case eatLove = "먹보 스타일"
    case cheerleader = "응원 단장 스타일"
    case silent = "돌하르방 스타일"
    case bodhisattva = "보살 스타일"
    
    var subInfo: String {
        switch self {
        case .director:
            return "\"당근과 채찍\"\n감독 스타일"
        case .mom:
            return "\"무조건 애정과 박수\"\n어미새 스타일"
        case .eatLove:
            return "\"맛집이 어디라구요?\"\n먹보 스타일"
        case .cheerleader:
            return "\"이곳이 나의 무대\"\n응원 단장 스타일"
        case .silent:
            return "\"...\"\n돌하르방 스타일"
        case .bodhisattva:
            return "\"그럴 수 있지\"\n보살 스타일"
        }
    }
    
    var iconImage: UIImage? {
        switch self {
        case .director:
            return UIImage(named: "EmptyDisable")
        case .mom:
            return UIImage(named: "EmptyDisable")
        case .eatLove:
            return UIImage(named: "EmptyDisable")
        case .cheerleader:
            return UIImage(named: "EmptyDisable")
        case .silent:
            return UIImage(named: "EmptyDisable")
        case .bodhisattva:
            return UIImage(named: "EmptyDisable")
        }
    }
    
    static let allCheerStyles: [CheerStyles] = CheerStyles.allCases
}
