//
//  ChatRoomReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/25/24.
//

import UIKit
import RxSwift
import ReactorKit

struct SenderInfo {
    let senderId: Int
    let nickName: String
    let imageUrl: String
}

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
        case setError(PresentationError?)
    }
    struct State {
        // View의 state를 관리한다.
        var messages: [ChatMessage] = []
//        var sendMessage: [ChatMessage] = [] // 보내는 중 메시지 -> 다시 전송 등 기능 필요
        var error: PresentationError?
    }
    
    var initialState: State
    private var myData: SenderInfo?
    private let roomId: Int
    private let disposeBag = DisposeBag()
    
    // TODO: - UseCase 연결 후 State로 변경하기
    var senderProfiles: [SenderInfo] = []
    init(roomId: Int) {
        self.initialState = State()
        self.roomId = roomId
        do {
            try setupMyData()
        } catch {
            action.onNext(.setError(ChatError.failedLoadMyData.convertToPresentationError()))
        }
        observeIncomingMessage()
//        setupSenderProfile()
        // 임시
        senderProfiles = [SenderInfo(senderId: 4, nickName: "네이벙", imageUrl: "https://catch-mate.s3.ap-northeast-2.amazonaws.com/d9214541-abb9-445e-96c2-194f992f4f0a_profile.jpg"),
                          SenderInfo(senderId: 7, nickName: "히희채팅테스트", imageUrl: "https://k.kakaocdn.net/dn/ieEGZ/btsK8rkUtPZ/koch7rFi1Bv9wEzQcknKY0/img_640x640.jpg")
        ]
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
            return Observable.empty()
        case .loadPeople:
            return Observable.empty()
        case .setError(let error):
            return Observable.just(.setError(error))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case .addMyMessage(let message):
            newState.messages.append(message)
            print(newState.messages)
        case .setMessages(let messages):
            newState.messages = messages
        case .setSenderInfo(let infos):
            self.senderProfiles = infos
        case .setError(let error):
            newState.error = error
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
    private func setupSenderProfile() {
        if let myData = myData {
            senderProfiles.append(myData)
        }
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
                guard let senderInfo = self?.senderProfiles.first(where: { $0.senderId == chatMessage.senderId }) else {
                    print("❌ [DEBUG] 보낸이 찾기 실패")
                    self?.action.onNext(.setError(ChatError.failedListenToMessages.convertToPresentationError()))
                    return
                }
                guard let type = ChatMessageType(serverRequest: chatMessage.messageType) else {
                    print("❌ [DEBUG] 메시지타입 디코딩 실패")
                    self?.action.onNext(.setError(ChatError.failedListenToMessages.convertToPresentationError()))
                    return
                }
                let newMessage = ChatMessage(userId: chatMessage.senderId, nickName: senderInfo.nickName, imageUrl: senderInfo.imageUrl, message: chatMessage.content, time: time, messageType: type)
                print("✅ [DEBUG] 메시지 파싱 성공 - \(newMessage)")
                self?.action.onNext(.receiveMessage(newMessage))
            })
            .disposed(by: disposeBag)
    }
    
    private func convertToSendMessage(content: String) -> Observable<ChatSocketMessage> {
        guard let senderId = myData?.senderId else {
            return .error(ChatError.failedLoadMyData)
        }
        let message = ChatSocketMessage(messageType: .talk, senderId: senderId, content: content)
        return .just(message)
    }
}
