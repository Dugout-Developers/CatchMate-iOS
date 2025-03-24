//
//  ExitChatRoomUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/14/25.
//

import UIKit
import RxSwift

protocol ExitChatRoomUseCase {
    func exitChat(chatId: Int) -> Observable<Void>
}

final class ExitChatRoomUseCaseImpl: ExitChatRoomUseCase {
    private let exitRepo: ExitChatRoomRepository
    init(exitRepo: ExitChatRoomRepository) {
        self.exitRepo = exitRepo
    }
    func exitChat(chatId: Int) -> Observable<Void> {
        return exitRepo.exitRoom(chatId: chatId)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "채팅방 나가기에 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "exit_chatroom", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
