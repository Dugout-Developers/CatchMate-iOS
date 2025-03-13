//
//  UnreadMessageRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 3/13/25.
//

import RxSwift

protocol UnreadMessageRepository {
    func unreadMessageState() -> Observable<(notification: Bool, chat: Bool)>
}
