//
//  Apply.swift
//  CatchMate
//
//  Created by 방유빈 on 7/17/24.
//

import UIKit

struct ApplyRequest {
    let applyPostId: String
    let addInfo: String?
}

struct MyApplyInfo {
    let enrollId: String
    let addInfo: String
}

struct Apply: Equatable {
    let id: String
    let post: Post
    let applicant: User
    let addText: String?
    let applyDate: Date = Date()
    
    static func == (lhs: Apply, rhs: Apply) -> Bool {
        return lhs.id == rhs.id
    }
    
    static var dummyData: [Apply] = [
        Apply(id: "1", post: Post(title: "연패는 안 된다 쉬었잖아 제발", writer: SimpleUser(userId: "1", nickName: "망곰보유구단", picture: "", favGudan: .dosun, gender: .woman, birthDate: "1999-01-01", cheerStyle: .cheerleader), homeTeam: .dosun, awayTeam: .lotte, cheerTeam: .dosun, date: "07.03", playTime: "18:30", location: "잠실", maxPerson: 4, currentPerson: 3, preferAge: 30, addInfo: "추가 정보"), applicant: User(id: "1", email: "ㄴㄴㄴ", nickName: "나요", birth: "2000-01-22", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), addText: "나 김치말이 국수 처돌인디"),
        Apply(id: "2", post: Post(title: "주말 홈경기 승률 뭐하냐? 제발 좀 이겨주세요 제발제발요.", writer: SimpleUser(userId: "4", nickName: "꼴등", picture: "", favGudan: .hanhwa, gender: .woman, birthDate: "1998-01-01", cheerStyle: .director), homeTeam: .hanhwa, awayTeam: .kt, cheerTeam: .hanhwa, date: "07.03", playTime: "18:30", location: "대전", maxPerson: 4, currentPerson: 4, preferAge: 20, addInfo: "추가 정보"), applicant: User(id: "1", email: "ㄴㄴㄴ", nickName: "나요", birth: "2000-01-22", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), addText: "오늘 지면 얘네 줘팸"),
        Apply(id: "3", post: Post(title: "도영아 너땜시 살어야", writer: SimpleUser(userId: "7", nickName: "도영아 사랑해", picture: "", favGudan: .kia, gender: .woman, birthDate: "2000-02-02", cheerStyle: .mom), homeTeam: .samsung, awayTeam: .kia, cheerTeam: .kia, date: "07.03", playTime: "18:30", location: "대구", maxPerson: 3, currentPerson: 2, preferAge: 0, addInfo: "추가 정보"), applicant: User(id: "1", email: "ㄴㄴㄴ", nickName: "나요", birth: "2000-01-22", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), addText: "김도영 30-30 보러 가즈아")
    ]
    
    static var recevieDummyData: [[Apply]] = [
        [Apply(id: "11", post: Post(title: "삼성 파랑 뺏으러 가자~", writer: SimpleUser(userId: "1", nickName: "나요", picture: "", favGudan: .hanhwa, gender: .man, birthDate: "2000-01-22", cheerStyle: .cheerleader), homeTeam: .samsung, awayTeam: .hanhwa, cheerTeam: .hanhwa, date: "08.08", playTime: "18:30", location: "대구", maxPerson: 3, currentPerson: 1, addInfo: "추가 정보"), applicant: User(id: "111", email: "email1", nickName: "파란이글스", birth: "1999-01-01", team: .hanhwa, gener: .man, cheerStyle: .cheerleader, profilePicture: "https://ifh.cc/g/MF3ZhH.jpg", pushAgreement: true, description: ""), addText: "저는 파란피가 흐릅니다"),
         Apply(id: "11", post: Post(title: "삼성 파랑 뺏으러 가자~", writer: SimpleUser(userId: "1", nickName: "나요", picture: "", favGudan: .hanhwa, gender: .man, birthDate: "2000-01-22", cheerStyle: .cheerleader), homeTeam: .samsung, awayTeam: .hanhwa, cheerTeam: .hanhwa, date: "08.08", playTime: "18:30", location: "대구", maxPerson: 3, currentPerson: 1, addInfo: "추가 정보"), applicant: User(id: "113", email: "email1", nickName: "보살", birth: "1999-01-01", team: .hanhwa, gener: .man, cheerStyle: .bodhisattva, profilePicture: "https://img.mbn.co.kr/filewww/news/other/2016/09/27/000109006000.jpg", pushAgreement: true, description: ""), addText: "가을 야구 가나요?"),
         Apply(id: "11", post: Post(title: "삼성 파랑 뺏으러 가자~", writer: SimpleUser(userId: "1", nickName: "나요", picture: "", favGudan: .hanhwa, gender: .man, birthDate: "2000-01-22", cheerStyle: .cheerleader), homeTeam: .samsung, awayTeam: .hanhwa, cheerTeam: .hanhwa, date: "08.08", playTime: "18:30", location: "대구", maxPerson: 3, currentPerson: 1, addInfo: "추가 정보"), applicant:  User(id: "112", email: "email1", nickName: "네네치킨", birth: "1999-01-01", team: .hanhwa, gener: .man, cheerStyle: .silent, profilePicture: "https://nenechicken.com/17_new/images/menu/30001.jpg", pushAgreement: true, description: ""), addText: "직관 승률 0"),
         Apply(id: "11", post: Post(title: "삼성 파랑 뺏으러 가자~", writer: SimpleUser(userId: "1", nickName: "나요", picture: "", favGudan: .hanhwa, gender: .man, birthDate: "2000-01-22", cheerStyle: .cheerleader), homeTeam: .samsung, awayTeam: .hanhwa, cheerTeam: .hanhwa, date: "08.08", playTime: "18:30", location: "대구", maxPerson: 3, currentPerson: 1, addInfo: "추가 정보"), applicant: User(id: "114", email: "email1", nickName: "동주맘", birth: "1995-01-01", team: .hanhwa, gener: .woman, cheerStyle: .mom, profilePicture: "https://img.hankyung.com/photo/202311/PYH2023100208470001300_P4.jpg", pushAgreement: true, description: ""), addText: "동주야 사랑해~"),
        ],
        [Apply(id: "12", post: Post(title: "저희경기 화나서 다른팀 보러왔습니다. 영업해주세요.", writer: SimpleUser(userId: "1", nickName: "나요", picture: "", favGudan: .hanhwa, gender: .man, birthDate: "2000-01-22", cheerStyle: .bodhisattva), homeTeam: .dosun, awayTeam: .kia, cheerTeam: .dosun, date: "08.15", playTime: "18:30", location: "잠실", maxPerson: 3, currentPerson: 1, addInfo: "두산 기아 안가립니다. 저를 데려가세요."), applicant:  User(id: "211", email: "email1", nickName: "잘생겼다이범호", birth: "1999-01-01", team: .kia, gener: .man, cheerStyle: .cheerleader, profilePicture: "https://img.mbn.co.kr/filewww/news/other/2015/06/18/891255810869.jpg", pushAgreement: true, description: ""), addText: "올해 1위각 기아 찍먹 ㄱ"),
         Apply(id: "12", post: Post(title: "저희경기 화나서 다른팀 보러왔습니다. 영업해주세요.", writer: SimpleUser(userId: "1", nickName: "나요", picture: "", favGudan: .hanhwa, gender: .man, birthDate: "2000-01-22", cheerStyle: .bodhisattva), homeTeam: .dosun, awayTeam: .kia, cheerTeam: .dosun, date: "08.15", playTime: "18:30", location: "잠실", maxPerson: 3, currentPerson: 1, addInfo: "두산 기아 안가립니다. 저를 데려가세요."), applicant:  User(id: "212", email: "email1", nickName: "수퍼노바", birth: "1999-01-01", team: .dosun, gener: .woman, cheerStyle: .cheerleader, profilePicture: "https://img-store.theqoo.net/vsTqIB.jpg", pushAgreement: true, description: ""), addText: "윈터 시구, 망곰 보유 구단 어떤데?"),
         Apply(id: "12", post: Post(title: "저희경기 화나서 다른팀 보러왔습니다. 영업해주세요.", writer: SimpleUser(userId: "1", nickName: "나요", picture: "", favGudan: .hanhwa, gender: .man, birthDate: "2000-01-22", cheerStyle: .bodhisattva), homeTeam: .dosun, awayTeam: .kia, cheerTeam: .dosun, date: "08.15", playTime: "18:30", location: "잠실", maxPerson: 3, currentPerson: 1, addInfo: "두산 기아 안가립니다. 저를 데려가세요."), applicant:  User(id: "213", email: "email1", nickName: "잘하자", birth: "1999-01-01", team: .kia, gener: .man, cheerStyle: nil, profilePicture: "https://img2.quasarzone.com/editor/2021/06/19/a5f8214f0684f13f76f98e17caf6ed81.jpg", pushAgreement: true, description: ""), addText: "아무거나 잡수시면 기아도 잡숴봐요."),
         Apply(id: "12", post: Post(title: "저희경기 화나서 다른팀 보러왔습니다. 영업해주세요.", writer: SimpleUser(userId: "1", nickName: "나요", picture: "", favGudan: .hanhwa, gender: .man, birthDate: "2000-01-22", cheerStyle: .bodhisattva), homeTeam: .dosun, awayTeam: .kia, cheerTeam: .dosun, date: "08.15", playTime: "18:30", location: "잠실", maxPerson: 3, currentPerson: 1, addInfo: "두산 기아 안가립니다. 저를 데려가세요."), applicant: User(id: "214", email: "email1", nickName: "엔씨뭐해", birth: "1995-01-01", team: .nc, gener: .man, cheerStyle: .director, profilePicture: "https://img2.quasarzone.com/editor/2021/06/19/a5f8214f0684f13f76f98e17caf6ed81.jpg", pushAgreement: true, description: ""), addText: "같이 갈아타요~"),
         Apply(id: "12", post: Post(title: "저희경기 화나서 다른팀 보러왔습니다. 영업해주세요.", writer: SimpleUser(userId: "1", nickName: "나요", picture: "", favGudan: .hanhwa, gender: .man, birthDate: "2000-01-22", cheerStyle: .bodhisattva), homeTeam: .dosun, awayTeam: .kia, cheerTeam: .dosun, date: "08.15", playTime: "18:30", location: "잠실", maxPerson: 3, currentPerson: 1, addInfo: "두산 기아 안가립니다. 저를 데려가세요."), applicant: User(id: "215", email: "email1", nickName: "프로직관러", birth: "1995-01-01", team: .dosun, gener: .woman, cheerStyle: .eatLove, profilePicture: "https://pds.joins.com/service/ssully/pd/2022/07/01/2022070116570979121.jpg", pushAgreement: true, description: ""), addText: "잠실의 주인 두산"),
        ]
    ]
}

