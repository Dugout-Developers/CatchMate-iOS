//
//  ChatRoomReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/25/24.
//

import UIKit
import RxSwift
import ReactorKit

enum ChatError: LocalizedErrorWithCode {
    case failedLoadMyData
    case failedLoadUsersData
    case failedStringToIntId
    case failedListenToMessages
    var statusCode: Int {
        switch self {
        case .failedLoadMyData:
            return -20001
        case .failedLoadUsersData:
            return -20002
        case .failedStringToIntId:
            return -20003
        case .failedListenToMessages:
            return -20004
        }
    }
    var errorDescription: String? {
        switch self {
        case .failedLoadMyData:
            return "내 정보 로드 실패"
        case .failedLoadUsersData:
            return "참여자 정보 로드 실패"
        case .failedStringToIntId:
            return "유저 id String To Int 변환 실패"
        case .failedListenToMessages:
            return "메시지 수신 실패"
        }
    }
    
    func convertToPresentationError() -> PresentationError {
        switch self {
        case .failedLoadMyData:
            return .unauthorized
        case .failedLoadUsersData, .failedStringToIntId, .failedListenToMessages:
            return .chatError
        }
    }
}

final class ChatRoomReactor: Reactor {
    enum Action {
        // 사용자의 입력과 상호작용하는 역할을 한다
        case subscribeRoom
        case unsubscribeRoom
        case loadMessages
        case loadPeople
        case sendMessage(String)
        case receiveMessage(ChatMessage)
        case setError(PresentationError?)
    }
    enum Mutation {
        case setMessages([ChatMessage])
        case setSenderInfo([SenderInfo])
        case addMyMessage(ChatMessage)
        case setIsLoading(Bool)
        case setIsLast(Bool)
        case setError(PresentationError?)
    }
    struct State {
        // View의 state를 관리한다.
        var messages: [ChatMessage] = []
//        var sendMessage: [ChatMessage] = [] // 보내는 중 메시지 -> 다시 전송 등 기능 필요
        var senderProfiles: [SenderInfo] = []
        var currentPage: Int = 0
        var isLast: Bool = false
        var isLoading: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    private var myData: SenderInfo?
    private let roomId: Int
    private let disposeBag = DisposeBag()
    private let managerInfo: ManagerInfo
    // MARK: - UseCase
    private let loadInfoUS: LoadChatInfoUseCase
    
    init(roomId: Int, managerInfo: ManagerInfo, loadInfoUS: LoadChatInfoUseCase) {
        self.initialState = State()
        self.roomId = roomId
        self.loadInfoUS = loadInfoUS
        self.managerInfo = managerInfo
        do {
            try setupMyData()
        } catch {
            action.onNext(.setError(ChatError.failedLoadMyData.convertToPresentationError()))
        }
        observeIncomingMessage()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .subscribeRoom:
            print("✅ 채팅방 \(roomId) 구독 요청")
            SocketService.shared?.subscribe(roomID: String(roomId))
            return .empty()
        case .unsubscribeRoom:
            print("🚫 채팅방 \(roomId) 구독 해제 요청")
            SocketService.shared?.unsubscribe(roomID: String(roomId))
            return .empty()
        case .sendMessage(let message):
            return convertToSendMessage(content: message)
                .flatMap { newMessage in
                    guard let jsonString = newMessage.encodeMessage() else {
                        print("❌ 메시지 인코딩 실패")
                        // TODO: - 메시지 보내는중으로 바꾸기
                        return Observable.just(Mutation.setError(.showToastMessage(message: "메시지 전송 실패")))
                    }
                    SocketService.shared?.sendMessage(to: String(self.roomId), message: jsonString)
                    print("📤 테스트 메시지 전송됨: \(jsonString)")
                    return Observable.empty()
                }
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setError(chatError.convertToPresentationError()))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .receiveMessage(let message):
            return Observable.just(Mutation.addMyMessage(message))
        case .loadMessages:
            if currentState.isLast || currentState.isLoading {
                return Observable.empty()
            } else {
                return loadInfoUS.loadChatMessages(chatId: roomId, page: currentState.currentPage)
                    .map({ [weak self] messages, isLast in
                        if isLast {
                            var newMessages: [ChatMessage] = []
                            let startMessage = ChatMessage(userId: 0, nickName: "", imageUrl: "", message: "", time: Date(), messageType: .startChat)
                            newMessages.append(startMessage)
                            if let managerInfo = self?.managerInfo {
                                let managerInfoMessage = ChatMessage(userId: managerInfo.id, nickName: managerInfo.nickName, imageUrl: "", message: "\(managerInfo.nickName) 님이 채팅에 참여했어요", time: Date(), messageType: .enterUser)
                                newMessages.append(managerInfoMessage)
                            }
                            return (newMessages + messages, true)
                        }
                        return (messages, isLast)
                    })
                    .flatMap { (messages, isLast) in
                        return Observable.concat([
                            Observable.just(.setIsLoading(true)),
                            Observable.just(.setMessages(messages)),
                            Observable.just(.setIsLast(isLast)),
                            Observable.just(.setIsLoading(false))
                        ])
                    }
                    .catch { error in
                        if let chatError = error as? ChatError {
                            return Observable.just(.setError(chatError.convertToPresentationError()))
                        } else {
                            return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                        }
                    }
            }
        case .loadPeople:
            return loadInfoUS.loadChatRoomUsers(chatId: roomId)
                .map { infos in
                    Mutation.setSenderInfo(infos)
                }
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setError(chatError.convertToPresentationError()))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .setError(let error):
            return Observable.just(.setError(error))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .addMyMessage(let message):
            newState.messages.append(message)
        case .setMessages(let messages):
            newState.messages.insert(contentsOf: messages, at: 0)
            newState.currentPage += 1
        case .setSenderInfo(let infos):
            newState.senderProfiles = infos
        case .setError(let error):
            newState.error = error
        case .setIsLoading(let state):
            newState.isLoading = state
        case .setIsLast(let state):
            newState.isLast = state
        }
        return newState
    }
    private func setupMyData() throws {
        guard let userInfo = SetupInfoService.shared.getUsertInfo() else {
            throw ChatError.failedLoadMyData
        }
        guard let userIntId = Int(userInfo.id) else {
            throw ChatError.failedStringToIntId
        }
        myData = SenderInfo(senderId: userIntId, nickName: userInfo.nickname, imageUrl: userInfo.imageUrl)
    }
    
    private func observeIncomingMessage() {
        // TODO: - Log 추가하기
        SocketService.shared?.messageObservable
            .filter({ [weak self] (roomId, _) in
                return Int(roomId) == self?.roomId
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_, message) in
                print("📩 메시지 수신: \(message)")
                guard let chatMessage = ChatSocketMessage.decode(from: message) else {
                    print("❌ [DEBUG] 메시지 디코딩 실패")
                    self?.action.onNext(.setError(ChatError.failedListenToMessages.convertToPresentationError()))
                    return
                }
                guard let time = DateHelper.shared.convertISOStringToDate(chatMessage.sendTime) else {
                    print("❌ [DEBUG] 시간 디코딩 실패")
                    self?.action.onNext(.setError(ChatError.failedListenToMessages.convertToPresentationError()))
                    return
                }
                guard let type = ChatMessageType(serverRequest: chatMessage.messageType) else {
                    print("❌ [DEBUG] 메시지타입 디코딩 실패")
                    self?.action.onNext(.setError(ChatError.failedListenToMessages.convertToPresentationError()))
                    return
                }
                let senderInfo: SenderInfo? = (type == .date) ? nil : self?.currentState.senderProfiles.first { $0.senderId == chatMessage.senderId }
                   
                let newMessage = ChatMessage(userId: chatMessage.senderId, nickName: senderInfo?.nickName ?? "", imageUrl: senderInfo?.imageUrl, message: chatMessage.content, time: time, messageType: type)
                print("✅ [DEBUG] 메시지 파싱 성공 - \(newMessage)")
                self?.action.onNext(.receiveMessage(newMessage))
            })
            .disposed(by: disposeBag)
    }
    
    private func convertToSendMessage(content: String) -> Observable<SendMessage> {
        guard let senderId = myData?.senderId else {
            return .error(ChatError.failedLoadMyData)
        }
        let message = SendMessage(messageType: .talk, senderId: senderId, content: content)
        return .just(message)
    }
}
