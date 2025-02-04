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
}

final class LoadChatInfoUseCaseImpl: LoadChatInfoUseCase {
    private let loadChatUsersRP: LoadChatUsersRepository
    
    init(loadChatUsersRP: LoadChatUsersRepository) {
        self.loadChatUsersRP = loadChatUsersRP
    }
    
    func loadChatRoomUsers(chatId: Int) -> Observable<[SenderInfo]> {
        return loadChatUsersRP.loadChatRoomUsers(chatId: chatId)
            .catch { error in
                if let localizedError = error as? LocalizedError, -1999...(-1000) ~= localizedError.statusCode {
                    // TokenError
                    return Observable.error(DomainError(error: error, context: .tokenUnavailable))
                }
                return Observable.error(DomainError(error: error, context: .action, message: "채팅방 정보를 불러오는데 실패했습니다."))
            }
    }
}
