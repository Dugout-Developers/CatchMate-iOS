//
//  ChatRoomReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/25/24.
//

import UIKit
import RxSwift
import ReactorKit

enum ScrollType {
    case startRoom
    case sendMyMessage
    case nextPage
    case receivedMessage
    case background
}
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
        case loadNotificationStatus
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
        case toggleNotification
        case loadMissedMessages
        case loadPostDetail(Void?)
    }
    enum Mutation {
        case setNotificationStatus(Bool)
        case setMessages([ChatMessage])
        case addMissedMessages([ChatMessage])
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
        case updateMissedMessage
        case setScrollTrigger(ScrollType)
        case setLoadPostDetailTrigger(Void?)
    }
    struct State {
        // View의 state를 관리한다.
        var messages: [ChatMessage] = []
        var missedMessages: [ChatMessage] = []
//        var sendMessage: [ChatMessage] = [] // 보내는 중 메시지 -> 다시 전송 등 기능 필요
        var senderProfiles: [SenderInfo] = []
        var isLast: Bool = false
        var isLoading: Bool = false
        var isNotification: Bool = false
        var exitTrigger: Void?
        var exportTrigger: Void?
        var error: PresentationError?
        var chatError: ChatError?
        var scrollTrigger: ScrollType = .startRoom
        var image: UIImage?
        var loadPostDetailTrigger: Void?
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
    private let notificationUS: SetChatRoomNotificationUseCase
    private let reloadChat = PublishSubject<Void>()
    init(chat: ChatRoomInfo, loadInfoUS: LoadChatInfoUseCase, updateImageUS: UpdateChatImageUseCase, exportUS: ExportChatUserUseCase, exitUS: ExitChatRoomUseCase, notificationUS: SetChatRoomNotificationUseCase) {
        self.initialState = State()
        self.loadInfoUS = loadInfoUS
        self.updateImageUS = updateImageUS
        self.exportUS = exportUS
        self.exitUS = exitUS
        self.notificationUS = notificationUS
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
        NotificationCenter.default.rx.notification(.loadMissedMessage)
            .map { _ in ChatRoomReactor.Action.loadMissedMessages }
            .bind(to: action)
            .disposed(by: disposeBag)
        reloadChat
            .withUnretained(self)
            .subscribe { reactor, _ in
                reactor.action.onNext(.loadMessages)
            }
            .disposed(by: disposeBag)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadNotificationStatus:
            return loadInfoUS.loadChatNotificationStatus(chatId: chat.chatRoomId)
                .flatMap { status in
                    return Observable.just(.setNotificationStatus(status))
                }
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setChatError(chatError))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .subscribeRoom:
            print("✅ 채팅방 \(chat.chatRoomId) 구독 요청")
            Task {
                await SocketService.shared?.connect(chatId:String(chat.chatRoomId))
            }

            return .empty()
        case .unsubscribeRoom:
            print("🚫 채팅방 \(chat.chatRoomId) 구독 해제 요청")
            SocketService.shared?.disconnect()
        
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
                    loadUser,
                    Observable.just(Mutation.addMyMessage(message)),
                    Observable.just(Mutation.setScrollTrigger(.receivedMessage))
                ])
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setChatError(chatError))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
            } else {
                return Observable.concat([
                    Observable.just(Mutation.addMyMessage(message)),
                    Observable.just(Mutation.setScrollTrigger(.receivedMessage))
                ])
            }
        case .loadMessages:
            if currentState.isLast || currentState.isLoading {
                return Observable.empty()
            } else {
                print("id: \(currentState.messages.first?.id)")
                return loadInfoUS.loadChatMessages(chatId: chat.chatRoomId, id: currentState.messages.first?.id)
                    .map({ [weak self] messages, isLast in
                        if isLast {
                            var newMessages: [ChatMessage] = []
                            let startMessage = ChatMessage(userId: 0, nickName: "", imageUrl: "", message: "", time: Date(), messageType: .startChat, isSocket: false, id: "")
                            newMessages.append(startMessage)
                            if let managerInfo = self?.chat.managerInfo {
                                let managerInfoMessage = ChatMessage(userId: managerInfo.id, nickName: managerInfo.nickName, imageUrl: "", message: "\(managerInfo.nickName) 님이 채팅에 참여했어요", time: Date(), messageType: .enterUser, isSocket: false, id: "")
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
                            Observable.just(.setIsLoading(false)),
                            Observable.just(.setScrollTrigger(.nextPage))
//                            Observable.just(.setScrollTrigger(isStart ? .startRoom : .nextPage))
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
        case .toggleNotification:
            let newState = !currentState.isNotification
            return notificationUS.setChatRoomNotification(roomId: chat.chatRoomId, isNotification: newState)
                .flatMap { _ in
                    return Observable.just(.setNotificationStatus(newState))
                }
                .catch { error in
                    if let chatError = error as? ChatError {
                        return Observable.just(.setChatError(chatError))
                    } else {
                        return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .loadMissedMessages:
            guard let firstMessage = currentState.messages.first else {
                reloadChat.onNext(())
                return .empty()
            }
            return loadMissedMessages(chatId: chat.chatRoomId, currentPage: 0, firstMessage: firstMessage)
        case .loadPostDetail(let trigger):
            return Observable.just(.setLoadPostDetailTrigger(trigger))
        }
    }

    private func loadMissedMessages(chatId: Int, currentPage: Int, firstMessage: ChatMessage) -> Observable<Mutation> {
        return loadInfoUS.loadChatMessages(chatId: chatId, id: nil)
            .flatMap { messageInfo -> Observable<Mutation> in
                var messages = messageInfo.messages
                if messageInfo.isLast {
                    var newMessages: [ChatMessage] = []
                    let startMessage = ChatMessage(userId: 0, nickName: "", imageUrl: "", message: "", time: Date(), messageType: .startChat, isSocket: false, id: "")
                    newMessages.append(startMessage)
                    let managerInfo = self.chat.managerInfo
                    let managerInfoMessage = ChatMessage(userId: managerInfo.id, nickName: managerInfo.nickName, imageUrl: "", message: "\(managerInfo.nickName) 님이 채팅에 참여했어요", time: Date(), messageType: .enterUser, isSocket: false, id: "")
                    newMessages.append(managerInfoMessage)
                    messages = newMessages + messages
                }
                // 현재 페이지가 마지막 페이지거나 처음 메시지가 포함된 메시지일 경우, 추가 후 종료 (더 이상 다음 페이지 요청 X)
                if messageInfo.isLast || messages.contains(where: {$0 == firstMessage}) {
                    return Observable.concat([
                        Observable.just(.addMissedMessages(messages)),
                        Observable.just(.setIsLast(messageInfo.isLast)),
                        Observable.just(.updateMissedMessage),
                        Observable.just(.setScrollTrigger(.background))
                    ])
                }
                // 처음 메시지를 못 찾았으므로 현재 메시지를 추가하고, 다음 페이지 로드
                return Observable.concat([
                    Observable.just(.addMissedMessages(messages)),  // 현재 페이지 메시지 추가
                    self.loadMissedMessages(chatId: chatId, currentPage: currentPage + 1, firstMessage: firstMessage) // 다음 페이지 요청
                ])
            }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case .setNotificationStatus(let state):
            newState.isNotification = state
        case .addMyMessage(let message):
            newState.messages.append(message)
        case .setMessages(let messages): // 이전 메시지 로드
            newState.messages.insert(contentsOf: messages, at: 0)
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
        case .addMissedMessages(let messages):
            newState.missedMessages.insert(contentsOf: messages, at: 0)
        case .updateMissedMessage:
            let newMessage = currentState.missedMessages
            newState.messages = newMessage
            newState.missedMessages.removeAll()
        case .setScrollTrigger(let type):
            if type == .receivedMessage {
                if currentState.messages.last?.userId == myData?.senderId {
                    newState.scrollTrigger = .sendMyMessage
                } else {
                    newState.scrollTrigger = .receivedMessage
                }
            } else {
                newState.scrollTrigger = type
            }
        case .setLoadPostDetailTrigger(let trigger):
            newState.loadPostDetailTrigger = trigger
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
                
                let newMessage = ChatMessage(userId: chatMessage.senderId, nickName: senderInfo?.nickName ?? "", imageUrl: senderInfo?.imageUrl, message: chatMessage.content, time: time, messageType: type, isSocket: true, id: chatMessage.chatMessageId)
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
