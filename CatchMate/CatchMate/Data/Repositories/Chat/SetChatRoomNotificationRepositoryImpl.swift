//
//  SetChatRoomNotificationRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 3/13/25.
//

import RxSwift

final class SetChatRoomNotificationRepositoryImpl: SetChatRoomNotificationRepository {
    private let setChatRoomNotificationDS: SetChatRoomNotificationDataSource
    init(setChatRoomNotificationDS: SetChatRoomNotificationDataSource) {
        self.setChatRoomNotificationDS = setChatRoomNotificationDS
    }
    func setChatRoomNotification(_ chatId: Int, _ isNotification: Bool) -> Observable<Void> {
        return setChatRoomNotificationDS.setChatRoomNotification(chatId: chatId, isNotification)
            .flatMap { state in
                if state {
                    return Observable.just(())
                } else {
                    return Observable.error(MappingError.stateFalse)
                }
            }
    }
}
