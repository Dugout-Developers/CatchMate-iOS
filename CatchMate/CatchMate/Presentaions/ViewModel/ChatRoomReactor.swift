//
//  ChatRoomReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/25/24.
//

import UIKit
import RxSwift
import ReactorKit

final class ChatRoomReactor: Reactor {
    enum Action {
        // 사용자의 입력과 상호작용하는 역할을 한다
        case loadMessages
        case sendMessage(String)
    }
    enum Mutation {
        case loadMessages([ChatMessage])
        case addMyMessage(String)
    }
    struct State {
        // View의 state를 관리한다.
        var messages: [ChatMessage] = []
    }
    
    var initialState: State
    private let chat: Chat
    private let user: User
    init(chat: Chat, user: User) {
        self.initialState = State()
        self.chat = chat
        self.user = user
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .sendMessage(let message):
            return Observable.just(Mutation.addMyMessage(message))
        case .loadMessages:
            return Observable.just(Mutation.loadMessages(chat.message))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .addMyMessage(let message):
            let newMessage = ChatMessage(text: message, user: user, date: Date(), messageType: 0)
            let otherMessage = ChatMessage(text: "제밟제발ㅇ바제방벶바아벶바아에제방베방베젱바베제ㅐㅂㅈ압제베앙젲배어ㅏㅂ재ㅔ방바ㅔㅈ아에자배ㅏㅔ", user: User(id: 2, email: "ㄴㄴㄴ", nickName: "부산예수님", birth: "2000-01-01", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: "profile", allAlarm: true, chatAlarm: true, enrollAlarm: true, eventAlarm: true), date: Date(), messageType: 0)
            newState.messages = currentState.messages + [newMessage, otherMessage]
        case .loadMessages(let messages):
            newState.messages = messages
        }
        return newState
    }
}
