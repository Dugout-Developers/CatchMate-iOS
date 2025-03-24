//
//  LoadChatMessageRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 2/4/25.
//

import RxSwift

protocol LoadChatMessageRepository {
    func loadChatMessage(_ chatId: Int, id: String?) -> Observable<(messages: [ChatSocketMessage], isLast: Bool)>
}
