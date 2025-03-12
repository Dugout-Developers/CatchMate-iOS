//
//  SetChatRoomNotificationUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 3/13/25.
//

import RxSwift

protocol SetChatRoomNotificationUseCase {
    func setChatRoomNotification(roomId: Int, isNotification: Bool) -> Observable<Void>
}

final class SetChatRoomNotificationUseCaseImpl: SetChatRoomNotificationUseCase {
    private let setChatRoomNotificationRepo: SetChatRoomNotificationRepository
    init(setChatRoomNotificationRepo: SetChatRoomNotificationRepository) {
        self.setChatRoomNotificationRepo = setChatRoomNotificationRepo
    }
    func setChatRoomNotification(roomId: Int, isNotification: Bool) -> RxSwift.Observable<Void> {
        return setChatRoomNotificationRepo.setChatRoomNotification(roomId, isNotification)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "채팅방 알림 설정에 실패했어요")
                LoggerService.shared.errorLog(domainError, domain: "set_chatroom_notification", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
    
    
}
