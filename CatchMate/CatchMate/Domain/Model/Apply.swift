//
//  Apply.swift
//  CatchMate
//
//  Created by 방유빈 on 7/17/24.
//

import UIKit

struct Apply: Equatable {
    let id: String
    let post: Post
    let applicantId: String
    let addText: String?
    
    static func == (lhs: Apply, rhs: Apply) -> Bool {
        return lhs.id == rhs.id
    }
    
    static var dummyData: [Apply] = [
        Apply(id: "1", post: Post(title: "연패는 안 된다 쉬었잖아 제발", writer: User(id: "1", email: "aa@aa.com", nickName: "망곰보유구단", birth: "1999-01-01", team: .dosun, gener: .woman, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), homeTeam: .dosun, awayTeam: .lotte, date: "07.03", playTime: "18:30", location: "잠실", maxPerson: 4, currentPerson: 3, preferAge: [20, 30]), applicantId: "1", addText: "나 김치말이 국수 처돌인디"),
        Apply(id: "2", post: Post(title: "주말 홈경기 승률 뭐하냐? 제발 좀 이겨주세요 제발제발요.", writer: User(id: "4", email: "aa@aa.com", nickName: "꼴등", birth: "1998-01-01", team: .hanhwa, gener: .woman, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), homeTeam: .hanhwa, awayTeam: .kt, date: "07.03", playTime: "18:30", location: "대전", maxPerson: 4, currentPerson: 4, preferAge: [20, 30]), applicantId: "1", addText: "오늘 지면 얘네 줘팸"),
        Apply(id: "3", post: Post(title: "도영아 너땜시 살어야", writer: User(id: "7", email: "aa@aa.com", nickName: "도영아사랑해", birth: "1999-10-10", team: .kia, gener: .woman, cheerStyle: .mom, profilePicture: nil, pushAgreement: true, description: ""), homeTeam: .samsung, awayTeam: .kia, date: "07.03", playTime: "18:30", location: "대구", maxPerson: 3, currentPerson: 2, preferAge: [20, 30]), applicantId: "1", addText: "김도영 30-30 보러 가즈아")
    ]
}
