//
//  ChatListReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import UIKit
import RxSwift
import ReactorKit

final class ChatListReactor: Reactor {
    enum Action {
        case loadChatList
        case selectChat(Chat?)
    }
    enum Mutation {
        case setChatList([Chat])
        case setSelectChat(Chat?)
    }
    struct State {
        var chatList: [Chat] = []
        var selectedChat: Chat?
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadChatList:
            return Observable.just(Mutation.setChatList(Chat.mockupData))
        case .selectChat(let chat):
            return Observable.just(Mutation.setSelectChat(chat))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setChatList(let chatList):
            newState.chatList = chatList
        case .setSelectChat(let chat):
            newState.selectedChat = chat
        }
        return newState
    }
}
