//
//  Post.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

struct Post: Identifiable, Equatable {
    var id: String
    let title: String
    let writer: User
    let homeTeam: Team
    let awayTeam: Team
//    let cheerTeam: Team -> 넣을지 말지 상의
    let date: String
    let playTime: String
    let location: String
    let maxPerson: Int
    let currentPerson: Int
    let preferGender: Gender?
    let preferAge: [Int]
    let addInfo: String?
    var isFinished: Bool {
        if currentPerson == maxPerson {
            return true
        } else {
            return false
        }
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(id: String = UUID().uuidString, title: String, writer: User, homeTeam: Team, awayTeam: Team, date: String, playTime: String, location: String, maxPerson: Int, currentPerson: Int, preferGender: Gender? = nil, preferAge: [Int] = [], addInfo: String? = nil) {
        self.id = id
        self.title = title
        self.writer = writer
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.date = date
        self.playTime = playTime
        self.location = location
        self.maxPerson = maxPerson
        self.currentPerson = currentPerson
        self.preferGender = preferGender
        self.preferAge = preferAge
        self.addInfo = addInfo
    }
}


extension Post {
    static var dummyPostData: [Post] = [
        Post(title: "연패는 안 된다 쉬었잖아 제발", writer: User(id: "1", email: "aa@aa.com", nickName: "망곰보유구단", birth: "1999-01-01", team: .dosun, gener: .woman, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), homeTeam: .dosun, awayTeam: .lotte, date: "07.03", playTime: "18:30", location: "잠실", maxPerson: 4, currentPerson: 3, preferAge: [20, 30]),
        Post(title: "괜찮겠어? 난 멈추는 법을 모르는 롯데인걸?", writer: User(id: "2", email: "aa@aa.com", nickName: "부산갈매기", birth: "1999-01-01", team: .lotte, gener: .man, cheerStyle: .cheerleader, profilePicture: nil, pushAgreement: true, description: ""), homeTeam: .dosun, awayTeam: .lotte, date: "07.03", playTime: "18:30", location: "잠실", maxPerson: 4, currentPerson: 3, preferAge: [20, 30]),
        Post(title: "돌고 돌아 류현진", writer: User(id: "3", email: "aa@aa.com", nickName: "치킨", birth: "2000-01-01", team: .hanhwa, gener: .woman, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), homeTeam: .hanhwa, awayTeam: .kt, date: "07.03", playTime: "18:30", location: "대전", maxPerson: 4, currentPerson: 3, preferAge: [20, 30], addInfo: "제발 좀 이겨주세요 미친놈들아!!!"),
        Post(title: "주말 홈경기 승률 뭐하냐? 제발 좀 이겨주세요 제발제발요.", writer: User(id: "4", email: "aa@aa.com", nickName: "꼴등", birth: "1998-01-01", team: .hanhwa, gener: .woman, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), homeTeam: .hanhwa, awayTeam: .kt, date: "07.03", playTime: "18:30", location: "대전", maxPerson: 4, currentPerson: 4, preferAge: [20, 30]),
        Post(title: "2등만 팬다", writer: User(id: "5", email: "aa@aa.com", nickName: "실책 1위", birth: "1997-02-02", team: .kia, gener: .man, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), homeTeam: .samsung, awayTeam: .kia, date: "07.03", playTime: "18:30", location: "대구", maxPerson: 2, currentPerson: 1, preferAge: [20, 30]),
        Post(title: "타이거즈 좋아하세요?", writer: User(id: "6", email: "aa@aa.com", nickName: "우승가자", birth: "1999-10-10", team: .kia, gener: .man, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), homeTeam: .samsung, awayTeam: .kia, date: "07.03", playTime: "18:30", location: "대구", maxPerson: 8, currentPerson: 4, preferAge: [20, 30]),
        Post(title: "도영아 너땜시 살어야", writer: User(id: "7", email: "aa@aa.com", nickName: "도영아사랑해", birth: "1999-10-10", team: .kia, gener: .woman, cheerStyle: .mom, profilePicture: nil, pushAgreement: true, description: ""), homeTeam: .samsung, awayTeam: .kia, date: "07.03", playTime: "18:30", location: "대구", maxPerson: 3, currentPerson: 2, preferAge: [20, 30])
    ]
    
    static var dummyFavoriteList: [Post]  = []
   
}
