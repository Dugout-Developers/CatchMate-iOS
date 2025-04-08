//
//  CheerStyles.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit

enum CheerStyles: String, CaseIterable, Codable {
    case director = "감독"
    case mom = "어미새"
    case cheerleader = "응원단장"
    case eatLove = "먹보"
    case silent = "돌하르방"
    case bodhisattva = "보살"
    
    var subInfo1: String {
        switch self {
        case .director:
            return "여기선 이렇게 하고 저기선"
        case .mom:
            return "못해도 너는 내 새끼"
        case .eatLove:
            return "그래서 여기 구장 맛집이"
        case .cheerleader:
            return "내가 바로 응원단장이고"
        case .silent:
            return "..."
        case .bodhisattva:
            return "그래 그럴 수 있지"
        }
    }
    var subInfo2: String {
        switch self {
        case .director:
            return "저렇게 했어야지"
        case .mom:
            return "무조건적 애정과 박수"
        case .eatLove:
            return "어디라구요?"
        case .cheerleader:
            return "내가 치어리더다"
        case .silent:
            return ""
        case .bodhisattva:
            return "그래도 잘했다"
        }
    }
    
    var iconImage: UIImage? {
        switch self {
        case .director:
            return UIImage(named: "director")
        case .mom:
            return UIImage(named: "mom")
        case .eatLove:
            return UIImage(named: "eatLove")
        case .cheerleader:
            return UIImage(named: "cheerleader")
        case .silent:
            return UIImage(named: "silent")
        case .bodhisattva:
            return UIImage(named: "bodhisattva")
        }
    }
    
    static let allCheerStyles: [CheerStyles] = CheerStyles.allCases
    
    static func random() -> CheerStyles {
        return allCheerStyles.randomElement() ?? .cheerleader
    }
}
