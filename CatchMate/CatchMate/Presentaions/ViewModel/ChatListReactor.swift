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
        case selectChat(ChatListInfo?)
        case loadNextPage
        case setError(PresentationError?)
    }
    enum Mutation {
        case setChatList(list: [ChatListInfo], isAppend: Bool)
        case setSelectChat(ChatListInfo?)
        case incrementPage
        case resetPage
        case setIsLast(Bool)
        case setLoading(Bool)
        case setError(PresentationError?)
    }
    struct State {
        var chatList: [ChatListInfo] = []
        var selectedChat: ChatListInfo?
        var currentPage: Int = 0
        var isLast: Bool = true
        var isLoading: Bool = true
        var error: PresentationError?
    }
    
    var initialState: State
    private let loadchatListUsecase: LoadChatListUseCase
    init(loadchatListUsecase: LoadChatListUseCase) {
        self.initialState = State()
        self.loadchatListUsecase = loadchatListUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadChatList:
            return loadchatListUsecase.loadChatList(page: 0)
                .flatMap { list, isLast -> Observable<Mutation> in
                    return Observable.concat([
                        Observable.just(Mutation.setLoading(true)),
                        Observable.just(.setChatList(list: list, isAppend: false)),
                        Observable.just(.resetPage),
                        Observable.just(.setIsLast(isLast)),
                        Observable.just(Mutation.setLoading(false))
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
            
        case .selectChat(let chat):
            return Observable.just(Mutation.setSelectChat(chat))
        case .loadNextPage:
            let nextPage = currentState.currentPage + 1
            
            if !currentState.isLoading || currentState.isLast {
                return Observable.empty()
            }
            
            return loadchatListUsecase.loadChatList(page: nextPage)
                .flatMap { list, isLast -> Observable<Mutation> in
                    return Observable.concat([
                        Observable.just(Mutation.setLoading(true)),
                        Observable.just(.setChatList(list: list, isAppend: true)),
                        Observable.just(.incrementPage),
                        Observable.just(.setIsLast(isLast)),
                        Observable.just(Mutation.setLoading(false))
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .setError(let error):
            return Observable.just(.setError(error))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case .setChatList(let chatList, let isAppend):
            if isAppend {
                newState.chatList.append(contentsOf: chatList)
            } else {
                newState.chatList = chatList
            }
        case .setSelectChat(let chat):
            newState.selectedChat = chat
        case .incrementPage:
            newState.currentPage += 1
        case .resetPage:
            newState.currentPage = 0
        case .setIsLast(let isLast):
            newState.isLast = isLast
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
