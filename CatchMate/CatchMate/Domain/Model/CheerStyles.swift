//
//  CheerStyles.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit

enum CheerStyles: String, CaseIterable {
    case director = "감독"
    case mom = "어미새"
    case cheerleader = "응원단장"
    case eatLove = "먹보"
    case silent = "돌하르방"
    case bodhisattva = "보살"
    
    var subInfo: String {
        switch self {
        case .director:
            return "여기선 이렇게 하고 저기선\n저렇게 했어야지"
        case .mom:
            return "못해도 너는 내 새끼\n무조건적 애정과 박수"
        case .eatLove:
            return "그래서 여기 구장 맛집이\n어디라구요?"
        case .cheerleader:
            return "내가 바로 응원단장이고\n내가 치어리더다"
        case .silent:
            return "..."
        case .bodhisattva:
            return "그래 그럴 수 있지\n그래도 잘했다"
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
