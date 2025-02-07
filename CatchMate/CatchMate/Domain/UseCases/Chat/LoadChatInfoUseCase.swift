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
        LoggerService.shared.log(level: .info, "채팅방 유저 정보 불러오기")
        return loadChatUsersRepo.loadChatRoomUsers(chatId: chatId)
            .catch { error in
                if let localizedError = error as? LocalizedError, -1999...(-1000) ~= localizedError.statusCode {
                    // TokenError
                    let domainError = DomainError(error: error, context: .tokenUnavailable)
                    LoggerService.shared.errorLog(domainError, domain: "load_chatusers", message: domainError.errorDescription)
                    return Observable.error(DomainError(error: error, context: .tokenUnavailable))
                }
                let domainError = DomainError(error: error, context: .pageLoad, message: "채팅방 정보를 불러오는데 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "load_chatusers", message: domainError.errorDescription)
                return Observable.error(domainError)
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
                LoggerService.shared.log(level: .info, "채팅방 이전 메시지 불러오기: \(page)페이지")
                return uc.loadChatMessageRepo.loadChatMessage(chatId, page: page)
                    .map { messages, isLast in
                        var newMessages = [ChatMessage]()
                        for message in messages {
                            let senderInfo = senders[message.senderId] ?? SenderInfo(senderId: message.senderId, nickName: "알 수 없음", imageUrl: "")
                            guard let date = DateHelper.shared.convertISOStringToDate(message.sendTime) else {
                                LoggerService.shared.log(level: .error, "메시지 시간 디코딩 실패")
                                continue
                            }
                            guard let type = ChatMessageType(serverRequest: message.messageType) else {
                                LoggerService.shared.log(level: .error, "메시지 타입 디코딩 실패")
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
