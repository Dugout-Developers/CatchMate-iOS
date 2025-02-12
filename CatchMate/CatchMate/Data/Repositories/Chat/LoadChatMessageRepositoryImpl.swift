//
//  LoadChatMessageRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/4/25.
//

import RxSwift

final class LoadChatMessageRepositoryImpl: LoadChatMessageRepository {
    private let loadMessageDS: LoadChatMessageDataSource
    
    init(loadMessageDS: LoadChatMessageDataSource) {
        self.loadMessageDS = loadMessageDS
    }
    
    func loadChatMessage(_ chatId: Int, page: Int) -> RxSwift.Observable<(messages: [ChatSocketMessage], isLast: Bool)> {
        return loadMessageDS.loadMessage(chatId, page: page)
            .map { dto in
                let dtoMessages = dto.chatMessageInfoList
                var messages = [ChatSocketMessage]()
                for message in dtoMessages {
                    let mesageType = message.senderId == -1 ? ChatMessageType.date : .talk
                    let chatMessage = ChatSocketMessage(messageType: mesageType, senderId: message.senderId, content: message.content, date: message.timeInfo.date)
                    messages.append(chatMessage)
                }
                return (messages, dto.isLast)
            }
    }
}

