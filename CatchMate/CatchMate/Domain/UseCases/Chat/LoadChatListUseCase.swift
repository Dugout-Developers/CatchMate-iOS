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
        return loadChatListRepository.loadChatList(page: page)
            .catch { error in
                if let localizedError = error as? LocalizedError, -1999...(-1000) ~= localizedError.statusCode {
                    // TokenError
                    return Observable.error(DomainError(error: error, context: .tokenUnavailable))
                }
                return Observable.just(([], true))
            }
    }
}
