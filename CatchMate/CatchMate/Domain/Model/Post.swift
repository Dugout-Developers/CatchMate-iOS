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
    let writer: SimpleUser
    let homeTeam: Team
    let awayTeam: Team
    let cheerTeam: Team 
    let date: String
    let playTime: String
    let location: String
    let maxPerson: Int
    let currentPerson: Int
    let preferGender: Gender?
    let preferAge: [Int]
    let addInfo: String
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
    
    init(id: String = UUID().uuidString, title: String, writer: SimpleUser, homeTeam: Team, awayTeam: Team, cheerTeam: Team, date: String, playTime: String, location: String, maxPerson: Int, currentPerson: Int, preferGender: Gender? = nil, preferAge: [Int] = [], addInfo: String) {
        self.id = id
        self.title = title
        self.writer = writer
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.cheerTeam = cheerTeam
        self.date = date
        self.playTime = playTime
        self.location = location
        self.maxPerson = maxPerson
        self.currentPerson = currentPerson
        self.preferGender = preferGender
        self.preferAge = preferAge
        self.addInfo = addInfo
    }
    
    // MARK: - 임시 (API 수정 후 변경 예정)
    init(post: RequestPost, writer: SimpleUser) {
        self.id = UUID().uuidString
        self.title = post.title
        self.writer = writer
        self.homeTeam = post.homeTeam
        self.awayTeam = post.awayTeam
        self.cheerTeam = post.cheerTeam
        self.date = DateHelper.shared.toString(from: post.date, format: "MM월 dd일")
        self.playTime = post.playTime
        self.location = post.location
        self.maxPerson = post.maxPerson
        self.currentPerson = 1
        self.preferGender = post.preferGender
        self.preferAge = post.preferAge
        self.addInfo = post.addInfo
    }
}


extension Post {
    static var dummyPostData: [Post] = [
        Post(id:"1", title: "연패는 안 된다 쉬었잖아 제발", writer: SimpleUser(userId: "1", nickName: "망곰보유구단", picture: "", favGudan: .dosun, gender: .woman, birthDate: "1999-01-01", cheerStyle: .cheerleader), homeTeam: .dosun, awayTeam: .lotte, cheerTeam: .dosun, date: "07.03", playTime: "18:30", location: "잠실", maxPerson: 4, currentPerson: 3, preferAge: [20, 30], addInfo: "추가 정보"),
        Post(title: "괜찮겠어? 난 멈추는 법을 모르는 롯데인걸?", writer: SimpleUser(userId: "2", nickName: "부산갈매기", picture: "", favGudan: .lotte, gender: .man, birthDate: "1999-01-01", cheerStyle: nil), homeTeam: .dosun, awayTeam: .lotte, cheerTeam: .lotte, date: "07.03", playTime: "18:30", location: "잠실", maxPerson: 4, currentPerson: 3, preferAge: [20, 30], addInfo: "추가 정보"),
        Post(title: "돌고 돌아 류현진", writer: SimpleUser(userId: "3", nickName: "치킨", picture: "", favGudan: .hanhwa, gender: .woman, birthDate: "2000-01-01", cheerStyle: .director), homeTeam: .hanhwa, awayTeam: .kt, cheerTeam: .hanhwa, date: "07.03", playTime: "18:30", location: "대전", maxPerson: 4, currentPerson: 3, preferAge: [20, 30], addInfo: "제발 좀 이겨주세요 미친놈들아!!!"),
        Post(title: "주말 홈경기 승률 뭐하냐? 제발 좀 이겨주세요 제발제발요.", writer: SimpleUser(userId: "4", nickName: "꼴등", picture: "", favGudan: .hanhwa, gender: .woman, birthDate: "1998-01-01", cheerStyle: .director), homeTeam: .hanhwa, awayTeam: .kt, cheerTeam: .hanhwa, date: "07.03", playTime: "18:30", location: "대전", maxPerson: 4, currentPerson: 4, preferAge: [20, 30], addInfo: "추가 정보"),
        Post(title: "2등만 팬다", writer: SimpleUser(userId: "5", nickName: "실책 1위", picture: "", favGudan: .kia, gender: .man, birthDate: "1997-02-02", cheerStyle: .bodhisattva), homeTeam: .samsung, awayTeam: .kia, cheerTeam: .kia, date: "07.03", playTime: "18:30", location: "대구", maxPerson: 2, currentPerson: 1, preferAge: [20, 30], addInfo: "추가 정보"),
        Post(title: "타이거즈 좋아하세요?", writer: SimpleUser(userId: "6", nickName: "우승 가자", picture: "", favGudan: .kia, gender: .man, birthDate: "1998-02-02", cheerStyle: .eatLove), homeTeam: .samsung, awayTeam: .kia, cheerTeam: .kia, date: "07.03", playTime: "18:30", location: "대구", maxPerson: 8, currentPerson: 4, preferAge: [20, 30], addInfo: "추가 정보"),
        Post(title: "도영아 너땜시 살어야", writer: SimpleUser(userId: "7", nickName: "도영아 사랑해", picture: "", favGudan: .kia, gender: .woman, birthDate: "2000-02-02", cheerStyle: .mom), homeTeam: .samsung, awayTeam: .kia, cheerTeam: .kia, date: "07.03", playTime: "18:30", location: "대구", maxPerson: 3, currentPerson: 2, preferAge: [20, 30], addInfo: "추가 정보")
    ]
}
