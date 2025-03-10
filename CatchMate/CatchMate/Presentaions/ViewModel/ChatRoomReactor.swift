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
    case failedLoadUsersData
    case failedStringToIntId
    case failedListenToMessages
    var statusCode: Int {
        switch self {
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
        case .failedLoadUsersData:
            return "참여자 정보 로드 실패"
        case .failedStringToIntId:
            return "유저 id String To Int 변환 실패"
        case .failedListenToMessages:
            return "메시지 수신 실패"
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
        case exitRoom
        case setError(PresentationError?)
        case setChatError(ChatError?)
        case loadImage(String)
        case changeImage(UIImage)
        case exportUser(Int)
    }
    enum Mutation {
        case setMessages([ChatMessage])
        case setSenderInfo([SenderInfo])
        case addMyMessage(ChatMessage)
        case setIsLoading(Bool)
        case setIsLast(Bool)
        case setExitTrigger(Void)
        case setExportTrigger(Void)
        case clearTrigger
        case setChatError(ChatError?)
        case setError(PresentationError?)
        
        case setImage(UIImage?)
    }
    struct State {
        // View의 state를 관리한다.
        var messages: [ChatMessage] = []
//        var sendMessage: [ChatMessage] = [] // 보내는 중 메시지 -> 다시 전송 등 기능 필요
        var senderProfiles: [SenderInfo] = []
        var currentPage: Int = 0
        var isLast: Bool = false
        var isLoading: Bool = false
        var exitTrigger: Void?
        var exportTrigger: Void?
        var error: PresentationError?
        var chatError: ChatError?
        var image: UIImage?
    }
    
    var initialState: State
    private var myData: SenderInfo?
    private let chat: ChatRoomInfo
    private let disposeBag = DisposeBag()

    // MARK: - UseCase
    private let loadInfoUS: LoadChatInfoUseCase
    private let updateImageUS: UpdateChatImageUseCase
    private let exportUS: ExportChatUserUseCase
    private let exitUS: ExitChatRoomUseCase
    
    init(chat: ChatRoomInfo, loadInfoUS: LoadChatInfoUseCase, updateImageUS: UpdateChatImageUseCase, exportUS: ExportChatUserUseCase, exitUS: ExitChatRoomUseCase) {
        self.initialState = State()
        self.loadInfoUS = loadInfoUS
        self.updateImageUS = updateImageUS
        self.exportUS = exportUS
        self.exitUS = exitUS
        self.chat = chat
        do {
            try setupMyData()
        } catch {
            if let chatError = error as? ChatError {
                action.onNext(.setChatError(chatError))
            } else {
                action.onNext(.setError(ErrorMapper.mapToPresentationError(error)))
            }
        }
        observeIncomingMessage()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .subscribeRoom:
            print("✅ 채팅방 \(chat.chatRoomId) 구독 요청")
            SocketService.shared?.subscribe(roomID: String(chat.chatRoomId))
            return .empty()
        case .unsubscribeRoom:
            print("🚫 채팅방 \(chat.chatRoomId) 구독 해제 요청")
            SocketService.shared?.unsubscribe(roomID: String(chat.chatRoomId))
            return .empty()
        case .sendMessage(let message):
            return convertToSendMessage(content: message)
                .flatMap { newMessage in
                    guard let jsonString = newMessage.encodeMessage() else {
                        print("❌ 메시지 인코딩 실패")
                        // TODO: - 메시지 보내는중으로 바꾸기
                        return Observable.just(Mutation.setError(.showToastMessage(message: "메시지 전송 실패")))
                    }
                    SocketService.shared?.sendMessage(to: String(self.chat.chatRoomId), message: jsonString)
                    print("📤 테스트 메시지 전송됨: \(jsonString)")
                    return Observable.empty()
                }
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setChatError(chatError))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .receiveMessage(let message):
            let loadUser = loadInfoUS.loadChatRoomUsers(chatId: chat.chatRoomId)
                .map { infos in
                    Mutation.setSenderInfo(infos)
                }
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setChatError(chatError))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
            
            if message.messageType == .enterUser || message.messageType == .leaveUser {
                return Observable.concat([
                    Observable.just(Mutation.addMyMessage(message)),
                    loadUser
                ])
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setChatError(chatError))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
            } else {
                return Observable.just(Mutation.addMyMessage(message))
            }
        case .loadMessages:
            if currentState.isLast || currentState.isLoading {
                return Observable.empty()
            } else {
                return loadInfoUS.loadChatMessages(chatId: chat.chatRoomId, page: currentState.currentPage)
                    .map({ [weak self] messages, isLast in
                        if isLast {
                            var newMessages: [ChatMessage] = []
                            let startMessage = ChatMessage(userId: 0, nickName: "", imageUrl: "", message: "", time: Date(), messageType: .startChat, isSocket: false)
                            newMessages.append(startMessage)
                            if let managerInfo = self?.chat.managerInfo {
                                let managerInfoMessage = ChatMessage(userId: managerInfo.id, nickName: managerInfo.nickName, imageUrl: "", message: "\(managerInfo.nickName) 님이 채팅에 참여했어요", time: Date(), messageType: .enterUser, isSocket: false)
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
                            return Observable.just(.setChatError(chatError))
                        } else {
                            return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                        }
                    }
            }
        case .loadPeople:
            return loadInfoUS.loadChatRoomUsers(chatId: chat.chatRoomId)
                .map { infos in
                    Mutation.setSenderInfo(infos)
                }
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setChatError(chatError))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .exitRoom:
            return exitUS.exitChat(chatId: chat.chatRoomId)
                .flatMap { _ in
                    return Observable.concat([
                        Observable.just(Mutation.setExitTrigger(())),
                        Observable.just(Mutation.clearTrigger).delay(.milliseconds(50), scheduler: MainScheduler.instance)
                    ])
                }
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setChatError(chatError))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .setError(let error):
            return Observable.just(.setError(error))
        case .setChatError(let chatError):
            return Observable.just(.setChatError(chatError))
            
        case .changeImage(let image):
            return updateImageUS.execute(chatId: chat.chatRoomId, image)
                .map { state in
                    if state {
                        return Mutation.setImage(image)
                    } else {
                        return Mutation.setError(PresentationError.showToastMessage(message: "이미지 업로드 실패"))
                    }
                }
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setChatError(chatError))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .loadImage(let urlString):
            return Observable.create { observer in
                ImageLoadHelper.urlToUIImage(urlString) { image in
                    observer.onNext(.setImage(image))
                    observer.onCompleted()
                }
                return Disposables.create()
            }
        case .exportUser(let userId):
            return exportUS.exportUser(chatId: chat.chatRoomId, userId: userId)
                .withUnretained(self)
                .flatMap { reactor, _ in
                    let newUsers = reactor.currentState.senderProfiles.filter {
                        $0.senderId != userId
                    }
                    return Observable.concat([
                        Observable.just(.setSenderInfo(newUsers)),
                        Observable.just(Mutation.setExportTrigger(())),
                        Observable.just(Mutation.clearTrigger).delay(.milliseconds(50), scheduler: MainScheduler.instance)
                    ])
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
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
        case .setChatError(let chatError):
            newState.chatError = chatError
        case .setIsLoading(let state):
            newState.isLoading = state
        case .setIsLast(let state):
            newState.isLast = state
            
        case .setImage(let image):
            if image != nil {
                newState.image = image
            } else {
                newState.image = chat.postInfo.cheerTeam.getFillImage
            }
        case .setExitTrigger():
            newState.exitTrigger = ()
        case .clearTrigger:
            newState.exitTrigger = nil
            newState.exportTrigger = nil
        case .setExportTrigger():
            newState.exportTrigger = ()
        }
        return newState
    }
    private func setupMyData() throws {
        guard let userInfo = SetupInfoService.shared.getUsertInfo() else {
            throw PresentationError.unauthorized
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
                if roomId == "/topic/chatList" {
                    return false
                }
                return Int(roomId) == self?.chat.chatRoomId
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_, message) in
                print("📩 메시지 수신: \(message)")
                guard let chatMessage = ChatSocketMessage.decode(from: message) else {
                    print("❌ [DEBUG] 메시지 디코딩 실패")
                    self?.action.onNext(.setChatError(ChatError.failedListenToMessages))
                    return
                }
                guard let time = DateHelper.shared.convertISOStringToDate(chatMessage.sendTime) else {
                    print("❌ [DEBUG] 시간 디코딩 실패")
                    self?.action.onNext(.setChatError(ChatError.failedListenToMessages))
                    return
                }
                guard let type = ChatMessageType(serverRequest: chatMessage.messageType) else {
                    print("❌ [DEBUG] 메시지타입 디코딩 실패")
                    self?.action.onNext(.setChatError(ChatError.failedListenToMessages))
                    return
                }
                let senderInfo: SenderInfo? = (type == .date) ? nil : self?.currentState.senderProfiles.first { $0.senderId == chatMessage.senderId }
                   
                let newMessage = ChatMessage(userId: chatMessage.senderId, nickName: senderInfo?.nickName ?? "", imageUrl: senderInfo?.imageUrl, message: chatMessage.content, time: time, messageType: type, isSocket: true)
                print("✅ [DEBUG] 메시지 파싱 성공 - \(newMessage)")
                self?.action.onNext(.receiveMessage(newMessage))
            })
            .disposed(by: disposeBag)
    }
    
    private func convertToSendMessage(content: String) -> Observable<SendMessage> {
        guard let senderId = myData?.senderId else {
            return .error(PresentationError.unauthorized)
        }
        let message = SendMessage(messageType: .talk, senderId: senderId, content: content)
        return .just(message)
    }
}
