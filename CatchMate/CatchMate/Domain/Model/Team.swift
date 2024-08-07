//
//  Team.swift
//  CatchMate
//
//  Created by 방유빈 on 6/16/24.
//

import UIKit

enum Team: String, CaseIterable, Codable {
    case nc = "다이노스"
    case samsung = "라이온즈"
    case ssg = "랜더스"
    case dosun = "베어스"
    case kt = "위즈"
    case hanhwa = "이글스"
    case lotte = "자이언츠"
    case kia = "타이거즈"
    case lg = "트윈스"
    case kiwoom = "히어로즈"
    case allTeamLove = "평화주의자"
    case yarine = "야린이"
    
    var fullName: String {
        switch self {
        case .nc:
            "엔씨다이노스"
        case .samsung:
            "삼성라이온즈"
        case .ssg:
            "신세계랜더스"
        case .dosun:
            "두산베어스"
        case .kt:
            "케이티위즈"
        case .hanhwa:
            "한화이글스"
        case .lotte:
            "롯데자이언츠"
        case .kia:
            "기아타이거즈"
        case .lg:
            "엘지트윈스"
        case .kiwoom:
            "키움히어로즈"
        case .allTeamLove:
            "평화주의자"
        case .yarine:
            "야린이"
        }
    }
    var place: [String]? {
        switch self {
        case .nc:
            return ["창원"]
        case .samsung:
            return ["대구", "포항"]
        case .ssg:
            return ["인천"]
        case .dosun:
            return ["잠실"]
        case .kt:
            return ["수원"]
        case .hanhwa:
            return ["대전", "청주"]
        case .lotte:
            return ["사직", "울산"]
        case .kia:
            return ["광주"]
        case .lg:
            return ["잠실"]
        case .kiwoom:
            return ["고척"]
        case .allTeamLove:
            return nil
        case .yarine:
            return nil
        }
    }
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
        case .allTeamLove:
            return UIImage(named: "EmptyDisable")
        case .yarine:
            return UIImage(named: "EmptyDisable")
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
        case .allTeamLove:
            return UIImage(named: "EmptyPrimary")
        case .yarine:
            return UIImage(named: "EmptyPrimary")
        }
    }
    
    var getLogoImage: UIImage? {
        switch self {
        case .nc:
            return UIImage(named: "dinos_logo")
        case .ssg:
            return UIImage(named: "landers_logo")
        case .kia:
            return UIImage(named: "tigers_logo")
        case .dosun:
            return UIImage(named: "bears_logo")
        case .hanhwa:
            return UIImage(named: "eagles_logo")
        case .lg:
            return UIImage(named: "twins_logo")
        case .samsung:
            return UIImage(named: "lions_logo")
        case .kiwoom:
            return UIImage(named: "kiwoom_logo")
        case .kt:
            return UIImage(named: "wiz_logo")
        case .lotte:
            return UIImage(named: "giants_logo")
        case .allTeamLove:
            return UIImage(named: "EmptyPrimary")
        case .yarine:
            return UIImage(named: "EmptyPrimary")
        }
    }
    
    var getTeamColor: UIColor {
        switch self {
        case .nc:
            return UIColor(hex: "#0C1C3A")
        case .ssg:
            return UIColor(hex: "#BD272C")
        case .kia:
            return UIColor(hex: "#D62E34")
        case .dosun:
            return UIColor(hex: "#12122E")
        case .hanhwa:
            return UIColor(hex: "#ED702D")
        case .lg:
            return UIColor(hex: "#B2243B")
        case .samsung:
            return UIColor(hex: "#2559A6")
        case .kiwoom:
            return UIColor(hex: "#761426")
        case .kt:
            return UIColor(hex: "#2B2A29")
        case .lotte:
            return UIColor(hex: "#0A1D3F")
        case .allTeamLove:
            return .cmPrimaryColor
        case .yarine:
            return .cmPrimaryColor
        }
    }
    
    static var allTeam: [Team] = Team.allCases.filter { $0 != .allTeamLove && $0 != .yarine }
    
    static var allTeamFull: [Team] = Team.allCases
}
