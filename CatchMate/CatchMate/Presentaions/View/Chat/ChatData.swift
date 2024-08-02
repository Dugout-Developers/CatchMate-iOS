//
//  ChatData.swift
//  CatchMate
//
//  Created by 방유빈 on 7/25/24.
//

import UIKit
// MARK: - 임시 데이터
struct Chat: Equatable {
    let chatId: String
    let createAt: Date
    let message: [ChatMessage]
    let post: Post
    let notRead: Int
    let enterTime: Date
    static let mockupData: [Chat] = [
        Chat(chatId: "1", createAt: ChatMessage.getDate(M: 7, d: 24, h: 14, m: 33), message: ChatMessage.mockupData, post: Post.dummyPostData[0], notRead: 0, enterTime: Date()),
        Chat(chatId: "1", createAt: ChatMessage.getDate(M: 7, d: 24, h: 14, m: 33), message: ChatMessage.mockupData, post: Post.dummyPostData[2], notRead: 0, enterTime:  ChatMessage.getDate(M: 7, d: 24, h: 20, m: 30)),
        Chat(chatId: "1", createAt: ChatMessage.getDate(M: 7, d: 24, h: 14, m: 33), message: ChatMessage.mockupData, post: Post.dummyPostData[3], notRead: 3, enterTime:  ChatMessage.getDate(M: 7, d: 25, h: 12, m: 53)),
        Chat(chatId: "1", createAt: ChatMessage.getDate(M: 7, d: 24, h: 14, m: 33), message: ChatMessage.mockupData, post: Post.dummyPostData[4], notRead: 2, enterTime: Date())
    ]
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.chatId == rhs.chatId
    }
}

struct ChatMessage {
    let text: String
    let user: User?
    let date: Date
    let messageType: Int // 0: 일반 메세지, 1: 입장 메시지, 2: 날짜 메시지, 3: 정보 메시지
    
    static let mockupData: [ChatMessage] = [
        ChatMessage(text: ".", user: nil, date: getDate(M: 7, d: 24, h: 13, m: 44), messageType: 2),
        ChatMessage(text: ".", user: nil, date: getDate(M: 7, d: 24, h: 13, m: 44), messageType: 3),
        ChatMessage(text: "부산예수님 님이 채팅에 참여했어요", user: User(id: "2", email: "ㄴㄴㄴ", nickName: "부산예수님", birth: "2000-01-01", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: "profile", pushAgreement: true, description: ""), date: getDate(M: 7, d: 24, h: 23, m: 58), messageType: 1),
        ChatMessage(text: "안녕하세요 예수님입니다.", user: User(id: "2", email: "ㄴㄴㄴ", nickName: "부산예수님", birth: "2000-01-01", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: "profile", pushAgreement: true, description: ""), date: getDate(M: 7, d: 24, h: 23, m: 58), messageType: 0),
        ChatMessage(text: "오늘 한화는 삼성 역전승 했던데 우리는 왜 그런 거 못 해요?", user: User(id: "2", email: "ㄴㄴㄴ", nickName: "부산예수님", birth: "2000-01-01", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: "profile", pushAgreement: true, description: ""), date: getDate(M: 7, d: 24, h: 23, m: 58), messageType: 0),
        ChatMessage(text: "끝까지 본 내가 바보다", user: User(id: "2", email: "ㄴㄴㄴ", nickName: "부산예수님", birth: "2000-01-01", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: "profile", pushAgreement: true, description: ""), date: getDate(M: 7, d: 24, h: 23, m: 59), messageType: 0),
        ChatMessage(text: "ㅋㅋ 그건 맞지", user: User(id: "1", email: "ㄴㄴㄴ", nickName: "나요", birth: "2000-01-22", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), date: getDate(M: 7, d: 24, h: 23, m: 59), messageType: 0),
        ChatMessage(text: ".", user: nil, date: getDate(M: 7, d: 25, h: 0, m: 0), messageType: 2),
        ChatMessage(text: "이번에 두산 윈터 시구하는 거 보셨나요", user: User(id: "1", email: "ㄴㄴㄴ", nickName: "나요", birth: "2000-01-22", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: nil, pushAgreement: true, description: ""), date: getDate(M: 7, d: 25, h: 0, m: 0), messageType: 0),
        ChatMessage(text: "직관했습니다. 윈터가 미래다.", user: User(id: "3", email: "ㄴㄴㄴ", nickName: "철웅아다이어트하자", birth: "1999-09-09", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: "bears_fill", pushAgreement: true, description: ""), date: getDate(M: 7, d: 25, h: 0, m: 2), messageType: 0),
        ChatMessage(text: "집관했습니다..", user: User(id: "2", email: "ㄴㄴㄴ", nickName: "부산예수님", birth: "2000-01-01", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: "profile", pushAgreement: true, description: ""), date: getDate(M: 7, d: 25, h: 0, m: 5), messageType: 0),
    ]
    
    static func getDate(M:Int, d: Int, h: Int, m: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2024
        dateComponents.month = M
        dateComponents.day = d
        dateComponents.hour = h
        dateComponents.minute = m

        // 현재 달력 객체를 가져옵니다.
        let calendar = Calendar.current
        return calendar.date(from: dateComponents)!
    }
}

