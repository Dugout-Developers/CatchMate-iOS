//
//  LoadChatListUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 1/26/25.
//

import UIKit
import RxSwift

protocol LoadChatListUseCase {
    func loadChatList(page: Int) -> Observable<(chatList: [ChatListInfo], isLast: Bool)>
}

final class LoadChatListUseCaseImpl: LoadChatListUseCase {
    private let loadChatListRepository: LoadChatListRepository
    
    init(loadChatListRepository: LoadChatListRepository) {
        self.loadChatListRepository = loadChatListRepository
    }
    
    func loadChatList(page: Int) -> RxSwift.Observable<(chatList: [ChatListInfo], isLast: Bool)> {
        LoggerService.shared.log(level: .info, "채팅리스트 불러오기")
        return loadChatListRepository.loadChatList(page: page)
            .catch { error in
                if let localizedError = error as? LocalizedError, -1999...(-1000) ~= localizedError.statusCode {
                    // TokenError
                    let domainError = DomainError(error: error, context: .tokenUnavailable)
                    LoggerService.shared.errorLog(domainError, domain: "load_chat", message: domainError.errorDescription)
                    return Observable.error(domainError)
                }
                LoggerService.shared.errorLog(error, domain: "load_chat", message: error.errorDescription)
                return Observable.just(([], true))
            }
    }
}
