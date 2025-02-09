//
//  User.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import UIKit

struct User: Codable, Equatable {
    var id: Int
    let email: String
    let nickName: String
    let birth: String
    let team: Team
    let gener: Gender
    let cheerStyle: CheerStyles?
    let profilePicture: String?
    let allAlarm, chatAlarm, enrollAlarm, eventAlarm: Bool
    
    var age: UInt {
        guard let birthdate = DateHelper.shared.toDate(from: birth, format: "yyyy-MM-dd") else {
            return 0
        }
        let today = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: today)
        return UInt(ageComponents.year ?? 0)
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

enum Gender: String, Codable {
    case woman = "여성"
    case man = "남성"
    case none = "성별 무관"
    
    var serverRequest: String {
        switch self {
        case .woman:
            "F"
        case .man:
            "M"
        case .none:
            "N"
        }
    }
    
    // 서버에서 받은 값을 기반으로 Gender 열거형 값을 반환하는 이니셜라이저
    init?(serverValue: String) {
        switch serverValue {
        case "F", "W", "f", "w":
            self = .woman
        case "M", "m":
            self = .man
        case "N":
            self = .none
        default:
            return nil
        }
    }
}

