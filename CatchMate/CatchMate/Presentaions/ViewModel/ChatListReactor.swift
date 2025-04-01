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
        case newMessage(Int)
        case loadNextPage
        case deleteChat(Int)
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
    private let deleteChatUsecase: ExitChatRoomUseCase
    private let disposeBag = DisposeBag()
    init(loadchatListUsecase: LoadChatListUseCase, deleteChatUsecase: ExitChatRoomUseCase) {
        self.initialState = State()
        self.loadchatListUsecase = loadchatListUsecase
        self.deleteChatUsecase = deleteChatUsecase
        observeIncomingMessage()
    }
    
    private func observeIncomingMessage() {
        // TODO: - Log 추가하기
        SocketService.shared?.messageObservable
            .filter{
                print($0)
                return $0.0 == "/topic/chatList"
            }
            .observe(on: MainScheduler.asyncInstance)
            .map({ (roomId, message) -> ChatListSocket? in
                guard let chatMessage = ChatListSocket.decode(from: message) else {
                    print("❌ [DEBUG] 메시지 디코딩 실패")
                    return nil
                }
                print("📩 메시지 수신 인코딩: \(chatMessage)")
                return chatMessage
            })
            .delay(.milliseconds(700), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                if let message = message {
                    self?.action.onNext(.newMessage(message.chatRoomId))
                }
            })
            .disposed(by: disposeBag)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .newMessage(let id):
            return loadchatListUsecase.loadChatList(page: 0)
                .flatMap { [weak self] list, _ -> Observable<Mutation> in
                    var newList = self?.currentState.chatList.filter { $0.chatRoomId != id }
                    newList?.insert(list[0], at: 0)
                    if let newList = newList {
                        return Observable.just(.setChatList(list: newList, isAppend: false))
                    }
                    return Observable.empty()
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
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
            
            if currentState.chatList.isEmpty {
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
        case .deleteChat(let index):
            let chatId = currentState.chatList[index].chatRoomId
            return deleteChatUsecase.exitChat(chatId: chatId)
                .withUnretained(self)
                .map { reactor, _ in
                    var newChatList = reactor.currentState.chatList
                    newChatList.remove(at: index)
                    return Mutation.setChatList(list: newChatList, isAppend: false)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
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
