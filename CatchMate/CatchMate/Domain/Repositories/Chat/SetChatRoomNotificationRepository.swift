//
//  SetChatRoomNotificationRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 3/13/25.
//

import RxSwift

protocol SetChatRoomNotificationRepository {
    func setChatRoomNotification(_ chatId: Int, _ isNotification: Bool) -> Observable<Void>
}
