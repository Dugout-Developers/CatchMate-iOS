//
//  UnreadMessageRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 3/13/25.
//

import RxSwift

final class UnreadMessageRepositoryImpl: UnreadMessageRepository {
    private let unreadMessageDS: LoadUnreadMessageDataSource
    init(unreadMessageDS: LoadUnreadMessageDataSource) {
        self.unreadMessageDS = unreadMessageDS
    }
    func unreadMessageState() -> RxSwift.Observable<(notification: Bool, chat: Bool)> {
        return unreadMessageDS.loadUnreadMessage()
            .map { dto in
                return (dto.hasUnreadNotification, dto.hasUnreadChat)
            }
    }
    
    
}
