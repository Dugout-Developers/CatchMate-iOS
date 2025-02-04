//
//  LoadChatInfoUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/4/25.
//

import UIKit
import RxSwift

protocol LoadChatInfoUseCase {
    func loadChatRoomUsers(chatId: Int) -> Observable<[SenderInfo]>
    func loadChatMessages(chatId: Int, page: Int) -> Observable<(messages: [ChatMessage], isLast: Bool)>
}

final class LoadChatInfoUseCaseImpl: LoadChatInfoUseCase {
    
    private let loadChatUsersRepo: LoadChatUsersRepository
    private let loadChatMessageRepo: LoadChatMessageRepository
    
    init(loadChatUsersRP: LoadChatUsersRepository, loadChatMessageRepo: LoadChatMessageRepository) {
        self.loadChatUsersRepo = loadChatUsersRP
        self.loadChatMessageRepo = loadChatMessageRepo
    }
    
    func loadChatRoomUsers(chatId: Int) -> Observable<[SenderInfo]> {
        return loadChatUsersRepo.loadChatRoomUsers(chatId: chatId)
            .catch { error in
                if let localizedError = error as? LocalizedError, -1999...(-1000) ~= localizedError.statusCode {
                    // TokenError
                    return Observable.error(DomainError(error: error, context: .tokenUnavailable))
                }
                return Observable.error(DomainError(error: error, context: .action, message: "채팅방 정보를 불러오는데 실패했습니다."))
            }
    }
    
    func loadChatMessages(chatId: Int, page: Int) -> RxSwift.Observable<(messages: [ChatMessage], isLast: Bool)> {
        return loadChatRoomUsers(chatId: chatId)
            .map { infos -> [Int: SenderInfo] in
                var senders: [Int: SenderInfo] = [:]
                for info in infos {
                    senders[info.senderId] = info
                }
                return senders
            }
            .withUnretained(self)
            .flatMap { uc, senders -> Observable<(messages: [ChatMessage], isLast: Bool)> in
                return uc.loadChatMessageRepo.loadChatMessage(chatId, page: page)
                    .map { messages, isLast in
                        var newMessages = [ChatMessage]()
                        for message in messages {
                            let senderInfo = senders[message.senderId] ?? SenderInfo(senderId: message.senderId, nickName: "알 수 없음", imageUrl: "")
                            guard let date = DateHelper.shared.convertISOStringToDate(message.sendTime) else {
                                print("❌ [DEBUG] 시간 디코딩 실패")
                                continue
                            }
                            guard let type = ChatMessageType(serverRequest: message.messageType) else {
                                print("❌ [DEBUG] 메시지타입 디코딩 실패")
                                continue
                            }
                            let newMessage = ChatMessage(userId: senderInfo.senderId, nickName: senderInfo.nickName, imageUrl: senderInfo.imageUrl, message: message.content, time: date, messageType: type)
                            newMessages.insert(newMessage, at: 0)
                        }
                        return (newMessages, isLast)
                    }
            }
    }
}
