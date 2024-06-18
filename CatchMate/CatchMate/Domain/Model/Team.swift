//
//  Team.swift
//  CatchMate
//
//  Created by 방유빈 on 6/16/24.
//

import UIKit

enum Team: String, CaseIterable {
    case nc = "다이노스"
    case ssg = "랜더스"
    case kia = "타이거즈"
    case dosun = "베어스"
    case hanhwa = "이글스"
    case lg = "트윈스"
    case samsung = "라이온즈"
    case kiwoom = "히어로즈"
    case kt = "위즈"
    case lotte = "자이언츠"
    
    var getDefaultsImage: UIImage? {
        switch self {
        case .nc:
            return UIImage(named: "dinos")
        case .ssg:
            return UIImage(named: "landers")
        case .kia:
            return UIImage(named: "tigers")
        case .dosun:
            return UIImage(named: "bears")
        case .hanhwa:
            return UIImage(named: "eagles")
        case .lg:
            return UIImage(named: "twins")
        case .samsung:
            return UIImage(named: "lions")
        case .kiwoom:
            return UIImage(named: "kiwoom")
        case .kt:
            return UIImage(named: "ktwiz")
        case .lotte:
            return UIImage(named: "giants")
        }
    }
    
    var getFillImage: UIImage? {
        switch self {
        case .nc:
            return UIImage(named: "dinos_fill")
        case .ssg:
            return UIImage(named: "landers_fill")
        case .kia:
            return UIImage(named: "tigers_fill")
        case .dosun:
            return UIImage(named: "bears_fill")
        case .hanhwa:
            return UIImage(named: "eagles_fill")
        case .lg:
            return UIImage(named: "twins_fill")
        case .samsung:
            return UIImage(named: "lions_fill")
        case .kiwoom:
            return UIImage(named: "kiwoom_fill")
        case .kt:
            return UIImage(named: "ktwiz_fill")
        case .lotte:
            return UIImage(named: "giants_fill")
        }
    }
    
    static var allTeam: [Team] = Team.allCases
}
