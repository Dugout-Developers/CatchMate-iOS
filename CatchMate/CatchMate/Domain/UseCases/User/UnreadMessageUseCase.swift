//
//  UnreadMessageUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 3/13/25.
//

import RxSwift

protocol UnreadMessageUseCase {
    func unreadMessageState() -> Observable<(notification: Bool, chat: Bool)>
}

final class UnreadMessageUseCaseImpl: UnreadMessageUseCase {
    private let unreadMessageRepo: UnreadMessageRepository
    
    init(unreadMessageRepo: UnreadMessageRepository) {
        self.unreadMessageRepo = unreadMessageRepo
    }
    func unreadMessageState() -> RxSwift.Observable<(notification: Bool, chat: Bool)> {
        return unreadMessageRepo.unreadMessageState()
    }
    
    
}
