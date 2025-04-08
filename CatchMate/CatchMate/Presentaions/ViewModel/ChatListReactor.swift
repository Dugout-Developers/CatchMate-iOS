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
        case newMessage(ChatListSocket)
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
    private let loadCahtUsecase: LoadChatDetailUseCase
    private let disposeBag = DisposeBag()
    init(loadchatListUsecase: LoadChatListUseCase, deleteChatUsecase: ExitChatRoomUseCase, loadCahtUsecase: LoadChatDetailUseCase) {
        self.initialState = State()
        self.loadchatListUsecase = loadchatListUsecase
        self.deleteChatUsecase = deleteChatUsecase
        self.loadCahtUsecase = loadCahtUsecase
        observeIncomingMessage()
    }
    
    private func observeIncomingMessage() {
        // TODO: - Log 추가하기
        SocketService.shared?.chatListObservable
            .observe(on: MainScheduler.asyncInstance)
            .map({ message -> ChatListSocket? in
                guard let chatMessage = ChatListSocket.decode(from: message) else {
                    print("❌ [DEBUG] 메시지 디코딩 실패")
                    return nil
                }
                print("📩 메시지 수신 인코딩: \(chatMessage)")
                return chatMessage
            })
//            .delay(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                if let message = message {
                    self?.action.onNext(.newMessage(message))
                }
            })
            .disposed(by: disposeBag)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .newMessage(let message):
            return loadCahtUsecase.loadChat(message.chatRoomId)
                .flatMap { [weak self] chat -> Observable<Mutation> in
                    guard let self = self else {
                        return Observable.empty()
                    }
                    print("ChatLoad: \(chat)")
                    let newChat = ChatListInfo(chatRoomId: chat.chatRoomId, postInfo: chat.postInfo, managerInfo: chat.managerInfo, lastMessage: message.content, lastMessageAt: Date(), currentPerson: chat.currentPerson, newChat: chat.newChat, notReadCount: chat.notReadCount, chatImage: chat.chatImage, notificationStatus: chat.notificationStatus)
                    var newList = currentState.chatList.filter { $0.chatRoomId != message.chatRoomId }
                    newList.insert(newChat, at: 0)
                    newList = Array(newList.prefix(currentState.chatList.count))
                    return Observable.just(.setChatList(list: newList, isAppend: false))
                    
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
